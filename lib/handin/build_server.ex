defmodule Handin.BuildServer do
  use GenServer

  import Ecto.Query, only: [from: 2]
  alias Handin.Assignments
  alias Handin.Assignments.Assignment
  alias Handin.AssignmentSubmissionFileUploader
  alias Handin.AssignmentFileUploader
  alias Handin.Assignments.AssignmentFile
  alias Handin.AssignmentSubmissions.AssignmentSubmissionFile
  alias Handin.Repo
  alias Handin.Assignments.Build

  @machine_api Application.compile_env(:handin, :machine_api_module)

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: name_for(state))
  end

  def name_for(%{assignment_id: assignment_id, user_id: user_id, role: role}) do
    {:global, "assignment:#{assignment_id}:module_user:#{user_id}:role:#{role}"}
  end

  @impl true
  def init(state) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :build,
      Build.changeset(%{
        assignment_id: state.assignment_id,
        status: :running,
        user_id: state.user_id,
        build_identifier: state.build_identifier
      })
    )
    |> Ecto.Multi.one(:assignment, fn _ ->
      from a in Assignment,
        where: a.id == ^state.assignment_id,
        preload: [:assignment_files, :assignment_tests]
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{build: build, assignment: assignment}} ->
        state = Map.merge(state, %{assignment: assignment, build: build, machine_id: nil})
        {:ok, state, {:continue, :create_machine}}

      {:error, :build, %{errors: errors} = _changeset, _} ->
        error_messages =
          Enum.map(errors, fn {field, {message, _}} ->
            "#{field}: #{message}"
          end)

        error_output = Enum.join(error_messages, "\n")

        handle_build_error(state, error_output)
        {:stop, :error, state}
    end
  end

  @impl true
  def handle_continue(:create_machine, state) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:machine, fn _, _ ->
      create_machine(state)
    end)
    |> Ecto.Multi.update(
      :build,
      fn %{machine: machine} ->
        Build.update_changeset(state.build, %{machine: machine["id"]})
      end
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{machine: machine, build: build}} ->
        state = %{state | machine_id: machine["id"], build: build}
        {:noreply, state, {:continue, :process_build}}

      {:error, :machine, reason, _} ->
        handle_build_error(state, reason)
        {:stop, reason, state}
    end
  end

  @impl true
  def handle_continue(:process_build, state) do
    with :ok <- download_files(state),
         :ok <- run_main_script(state),
         :ok <- run_test_scripts(state) do
      finalize_build(state)
    else
      {:error, reason} ->
        handle_build_error(state, reason)
    end

    {:stop, :normal, state}
  end

  defp download_files(state) do
    case @machine_api.exec(state.machine_id, "sh ./files.sh") do
      {:ok, %{"exit_code" => 0}} -> :ok
      _ -> {:error, :file_download_failed}
    end
  end

  defp run_main_script(state) do
    case @machine_api.exec(state.machine_id, "sh ./main.sh") do
      {:ok, %{"exit_code" => 0} = response} ->
        handle_run_script_results(state, %{output: response["stdout"], script_state: :pass})

        :ok

      {:ok, reason} ->
        handle_run_script_results(state, %{output: reason["stderr"], script_state: :fail})

        {:error, :main_script_failed}
    end
  end

  defp run_test_scripts(state) do
    Enum.each(state.assignment.assignment_tests, &run_single_test(state, &1))
    :ok
  end

  defp run_single_test(state, assignment_test) do
    case @machine_api.exec(state.machine_id, "sh ./#{assignment_test.id}.sh") do
      {:ok, %{"exit_code" => 0} = response} ->
        handle_successful_test(state, assignment_test, response)

      {:ok, response} ->
        handle_failed_test(state, assignment_test, response)

      {:error, reason} ->
        handle_error_test(state, assignment_test, reason)
    end
  end

  defp handle_successful_test(state, assignment_test, response) do
    Process.sleep(3000)

    case Jason.decode(response["stdout"]) do
      {:ok, decoded_response} ->
        save_test_results(state, assignment_test, decoded_response)

      {:error, _} ->
        handle_json_parse_error(state, assignment_test, response["stdout"])
    end
  end

  defp handle_failed_test(state, assignment_test, response) do
    save_test_results(state, assignment_test, %{
      "state" => "fail",
      "output" => response["stderr"]
    })
  end

  defp handle_error_test(state, assignment_test, reason) do
    save_test_results(state, assignment_test, %{
      "state" => "fail",
      "output" => reason
    })
  end

  defp create_machine(state) do
    state
    |> build_machine_config()
    |> Jason.encode!()
    |> @machine_api.create()
  end

  defp build_machine_config(state) do
    %{
      config: %{
        init: %{exec: ["/bin/sleep", "inf"]},
        auto_destroy: true,
        image: state.image,
        files: build_all_scripts(state)
      }
    }
  end

  defp build_all_scripts(state) do
    build_main_script(state.assignment) ++
      build_file_download_script(state.assignment) ++
      build_upload_script(state.assignment, state) ++
      build_check_script(state.assignment) ++
      build_tests_scripts(state.assignment)
  end

  defp handle_run_script_results(state, %{script_state: script_state, output: output}) do
    Assignments.save_run_script_results(%{
      assignment_id: state.assignment.id,
      state: script_state,
      build_id: state.build.id,
      user_id: state.user_id,
      output: output
    })

    log_and_broadcast(state, "test_result")
  end

  defp save_test_results(state, assignment_test, response) do
    test_state = if response["state"] == "pass", do: :pass, else: :fail

    output =
      if test_state == :pass, do: response["output"], else: response["output"]

    Assignments.save_test_results(%{
      assignment_test_id: assignment_test.id,
      state: test_state,
      build_id: state.build.id,
      user_id: state.user_id,
      output: output
    })

    log_and_broadcast(state, "test_result")
  end

  defp handle_json_parse_error(state, assignment_test, data) do
    save_test_results(state, assignment_test, %{
      "state" => "fail",
      "output" => "Error parsing json: #{data}"
    })
  end

  defp finalize_build(state) do
    Assignments.update_build(state.build, %{status: :completed})
    Assignments.get_logs(state.build.id)
    broadcast_build_completed(state)
    upload_and_stop_machine(state)
  end

  defp broadcast_build_completed(state) do
    channel =
      "assignment:#{state.assignment_id}:module_user:#{state.user_id}:role:#{state.role}"

    HandinWeb.Endpoint.broadcast!(channel, "build_completed", state.build.id)
  end

  defp upload_and_stop_machine(state) do
    @machine_api.exec(state.machine_id, "sh ./upload.sh")
    @machine_api.stop(state.machine_id)
  end

  defp handle_build_error(%{build: _} = state, reason) do
    Assignments.update_build(state.build, %{status: :failed})
    log_map = %{output: inspect(reason), type: :runtime, build_id: state.build.id}
    Assignments.log(log_map)
    log_and_broadcast(state, "log")
  end

  defp handle_build_error(state, reason) do
    state
    |> Map.put(:message, inspect(reason))
    |> log_and_broadcast("log")
  end

  defp log_and_broadcast(
         %{build: build} = state,
         result_type
       ) do
    channel =
      "assignment:#{state.assignment_id}:module_user:#{state.user_id}:role:#{state.role}"

    HandinWeb.Endpoint.broadcast!(channel, result_type, build.id)
  end

  defp log_and_broadcast(state, "log") do
    channel =
      "assignment:#{state.assignment_id}:module_user:#{state.user_id}:role:#{state.role}"

    HandinWeb.Endpoint.broadcast!(channel, "build_failed", state.message)
  end

  defp build_check_script(assignment) do
    assignment.assignment_tests
    |> Enum.map(fn assignment_test ->
      template = """
      #!/bin/bash
      if diff -q #{assignment_test.id}.out #{assignment_test.expected_output_file} >/dev/null; then
        state="pass"
      else
        state="fail"
      fi
      JSON_FMT='{"state": "%s"}'
      printf "$JSON_FMT" "$state"
      """

      %{
        "guest_path" => "/check_#{assignment_test.id}.sh",
        "raw_value" => Base.encode64(template)
      }
    end)
  end

  defp build_file_download_script(assignment) do
    template = """
    #!/bin/bash
    set -e
    download_file() {
      local url="$1"
      local filename="$2"
      curl -sSL -o "$filename" "$url" || echo "Failed to download $filename"
    }
    """

    assignment_files = assignment.assignment_files

    download_commands =
      assignment_files
      |> Enum.map_join("\n", &generate_download_command/1)

    [
      %{
        "guest_path" => "/files.sh",
        "raw_value" => Base.encode64(template <> download_commands)
      }
    ]
  end

  defp generate_download_command(assignment_file) do
    url = get_file_url(assignment_file)
    ~s(download_file "#{url}" "#{assignment_file.file.file_name}")
  end

  defp get_file_url(%AssignmentSubmissionFile{} = file) do
    AssignmentSubmissionFileUploader.url({file.file.file_name, file}, signed: true)
  end

  defp get_file_url(%AssignmentFile{} = file) do
    AssignmentFileUploader.url({file.file.file_name, file}, signed: true)
  end

  defp build_main_script(assignment) do
    template = """
      #!bin/bash
      #{assignment.run_script}
    """

    [
      %{
        "guest_path" => "/main.sh",
        "raw_value" => Base.encode64(template)
      }
    ]
  end

  defp build_upload_script(assignment, state) do
    config = ExAws.Config.new(:s3, Application.get_all_env(:ex_aws))

    template = """
    #!/bin/bash
    """

    curls =
      assignment.assignment_tests
      |> Enum.map(fn assignment_test ->
        {:ok, presigned_url} =
          ExAws.S3.presigned_url(
            config,
            :put,
            "handin-dev",
            "uploads/assignments/#{assignment.id}/users/#{state.user_id}/submission/#{assignment_test.id}.out",
            expires_in: 6000
          )

        "curl --request PUT --upload-file \"#{assignment_test.id}.out\" \"#{presigned_url}\""
      end)

    template = template <> Enum.join(curls, "\n")

    [
      %{
        "guest_path" => "/upload.sh",
        "raw_value" => Base.encode64(template)
      }
    ]
  end

  defp build_tests_scripts(assignment) do
    assignment.assignment_tests
    |> Enum.map(&build_test_script/1)
  end

  defp build_test_script(assignment_test) do
    template = get_test_template(assignment_test)

    %{
      "guest_path" => "/#{assignment_test.id}.sh",
      "raw_value" => Base.encode64(template)
    }
  end

  defp get_test_template(%{enable_custom_test: true} = assignment_test) do
    assignment_test.custom_test
  end

  defp get_test_template(%{expected_output_type: :string} = assignment_test) do
    """
    #!/bin/sh
    set -e
    escape_json() {
      printf '%s' "$1" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g'
    }
    output=$(#{assignment_test.command})
    echo "$output" > #{assignment_test.id}.out
    expected_output=#{assignment_test.expected_output_text}
    if [ "$output" = "$expected_output" ]; then
      printf '{"state":"pass","output":"%s"}' "$(escape_json "$output")"
    else
      printf '{"state":"fail","output":"%s","expected":"%s"}' "$(escape_json "$output")" "$(escape_json "$expected_output")"
    fi
    """
  end

  defp get_test_template(assignment_test) do
    """
    #!/bin/sh
    set -e
    escape_json() {
      printf '%s' "$1" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g'
    }
    output=$(#{assignment_test.command})
    echo "$output" > #{assignment_test.id}.out
    if diff -wi #{assignment_test.id}.out #{assignment_test.expected_output_file} >/dev/null; then
      printf '{"state":"pass","output":"%s"}' "$(escape_json "$output")"
    else
      expected=$(cat #{assignment_test.expected_output_file})
      printf '{"state":"fail","output":"%s","expected":"%s"}' "$(escape_json "$output")" "$(escape_json "$expected")"
    fi
    """
  end
end
