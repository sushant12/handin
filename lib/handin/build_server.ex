defmodule Handin.BuildServer do
  use GenServer
  alias Handin.Assignments
  alias Handin.AssignmentSubmissionFileUploader
  alias Handin.AssignmentSubmission.AssignmentSubmissionFile

  @machine_api Application.compile_env(:handin, :machine_api_module)

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: name_for(state))
  end

  def name_for(%{type: "assignment_tests", assignment_id: assignment_id}) do
    {:global, "build:assignment_tests:#{assignment_id}"}
  end

  def name_for(%{type: type, assignment_submission_id: assignment_submission_id}) do
    {:global, "build:#{type}:#{assignment_submission_id}"}
  end

  @impl true
  def init(state) do
    assignment = Assignments.get_assignment!(state.assignment_id)
    {:ok, build} = create_new_build(assignment, state.user_id)
    state = Map.merge(state, %{assignment: assignment, build: build})
    {:ok, state, {:continue, :create_machine}}
  end

  @impl true
  def handle_continue(:create_machine, state) do
    case create_and_start_machine(state) do
      {:ok, machine_id, build} ->
        state = %{state | machine_id: machine_id, build: build}
        {:noreply, state, {:continue, :process_build}}

      :error ->
        Assignments.update_build(state.build, %{status: :failed})
        {:stop, "Failed To Create Container", state}
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

  defp create_new_build(assignment, user_id) do
    Assignments.new_build(%{
      assignment_id: assignment.id,
      status: :running,
      user_id: user_id
    })
  end

  defp create_and_start_machine(state) do
    with {:ok, machine} <- create_machine(state),
         true <- machine_started?(machine),
         {:ok, build} <- update_build_with_machine_id(state.build, machine["id"]) do
      {:ok, machine["id"], build}
    else
      _ -> :error
    end
  end

  defp create_machine(state) do
    @machine_api.create(Jason.encode!(build_machine_config(state)))
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
      build_file_download_script(state.assignment, state.type, state.user_id) ++
      build_upload_script(state.assignment, state) ++
      build_check_script(state.assignment) ++
      build_tests_scripts(state.assignment)
  end

  defp machine_started?(machine) do
    case @machine_api.status(machine["id"]) do
      {:ok, %{"state" => state}} when state in ["created", "starting"] ->
        :timer.sleep(1000)
        machine_started?(machine)

      _ ->
        true
    end
  end

  defp update_build_with_machine_id(build, machine_id) do
    Assignments.update_build(build, %{machine_id: machine_id})
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
        save_run_script_results(state, :pass)

        log_and_broadcast(
          state.build,
          %{command: "sh ./main.sh", output: response["stdout"]},
          state
        )

        :ok

      {:ok, reason} ->
        save_run_script_results(state, :fail)

        log_and_broadcast(
          state.build,
          %{command: "sh ./main.sh", output: reason["stderr"]},
          state
        )

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
    :timer.sleep(3000)

    case Jason.decode(response["stdout"]) do
      {:ok, decoded_response} ->
        save_test_results(state, assignment_test, decoded_response)
        log_test_result(state, assignment_test, decoded_response)

      {:error, _} ->
        handle_json_parse_error(state, assignment_test, response["stdout"])
    end
  end

  defp handle_failed_test(state, assignment_test, response) do
    save_test_results(state, assignment_test, %{"state" => "fail"})

    log_and_broadcast(
      state.build,
      %{
        command: assignment_test.command,
        assignment_test_id: assignment_test.id,
        output: response["stderr"]
      },
      state
    )
  end

  defp handle_error_test(state, assignment_test, reason) do
    save_test_results(state, assignment_test, %{"state" => "fail"})

    log_and_broadcast(
      state.build,
      %{
        command: assignment_test.command,
        assignment_test_id: assignment_test.id,
        output: reason
      },
      state
    )
  end

  defp save_run_script_results(state, script_state) do
    Assignments.save_run_script_results(%{
      assignment_id: state.assignment.id,
      state: script_state,
      build_id: state.build.id,
      user_id: state.user_id
    })
  end

  defp save_test_results(state, assignment_test, response) do
    test_state = if response["state"] == "pass", do: :pass, else: :fail

    Assignments.save_test_results(%{
      assignment_test_id: assignment_test.id,
      state: test_state,
      build_id: state.build.id,
      user_id: state.user_id
    })
  end

  defp log_test_result(state, assignment_test, response) do
    log_and_broadcast(
      state.build,
      %{
        command: assignment_test.command,
        assignment_test_id: assignment_test.id,
        output: response["output"],
        expected_output: response["expected_output"]
      },
      state
    )
  end

  defp handle_json_parse_error(state, assignment_test, data) do
    save_test_results(state, assignment_test, %{"state" => "fail"})

    log_and_broadcast(
      state.build,
      %{
        command: assignment_test.command,
        assignment_test_id: assignment_test.id,
        output: "Error parsing json: #{data}"
      },
      state
    )
  end

  defp finalize_build(state) do
    Assignments.update_build(state.build, %{status: :completed})
    Assignments.get_logs(state.build.id)
    broadcast_build_completed(state)
    handle_assignment_submission(state)
    upload_and_stop_machine(state)
  end

  defp broadcast_build_completed(state) do
    channel =
      if state.type == "assignment_tests",
        do: "build:#{state.type}:#{state.assignment_id}",
        else: "build:#{state.type}:#{state.assignment_submission_id}"

    HandinWeb.Endpoint.broadcast!(channel, "build_completed", state.build.id)
  end

  defp handle_assignment_submission(state) do
    if state.type != "assignment_tests" do
      Assignments.submit_assignment(
        state.assignment_submission_id,
        state.assignment.enable_max_attempts
      )

      submission = Assignments.get_submission(state.assignment.id, state.user_id)
      Assignments.evaluate_marks(submission.id, state.build.id)
    end
  end

  defp upload_and_stop_machine(state) do
    @machine_api.exec(state.machine_id, "sh ./upload.sh")
    @machine_api.stop(state.machine_id)
  end

  defp handle_build_error(state, reason) do
    Assignments.update_build(state.build, %{status: :failed})
    log_and_broadcast(state.build, %{command: "Build failed", output: inspect(reason)}, state)
  end

  defp log_and_broadcast(build, log_map, state) do
    log_map = Map.put(log_map, :build_id, build.id)
    Assignments.log(log_map)

    channel =
      if state.type == "assignment_tests",
        do: "build:#{state.type}:#{state.assignment_id}",
        else: "build:#{state.type}:#{state.assignment_submission_id}"

    HandinWeb.Endpoint.broadcast!(channel, "test_result", build.id)
  end

  # The following functions (build_check_script, build_file_download_script, build_main_script, build_upload_script, build_tests_scripts)
  # remain unchanged as they are helper functions for creating scripts.
  # Their implementations are kept as is to maintain the existing functionality.

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

  defp build_file_download_script(assignment, type, user_id) do
    template = """
    #!bin/bash
    """

    assignment_files =
      if type == "assignment_tests" do
        assignment.support_files ++ assignment.solution_files
      else
        assignment.support_files ++ Assignments.get_submission_files(assignment.id, user_id)
      end

    urls =
      assignment_files
      |> Enum.map(fn assignment_file ->
        case assignment_file do
          %AssignmentSubmissionFile{} = assignment_file ->
            AssignmentSubmissionFileUploader.url(
              {assignment_file.file.file_name, assignment_file},
              signed: true
            )

          _ ->
            nil
            # SupportFileUploader.url({assignment_file.file.file_name, assignment_file},
            #   signed: true
            # )
        end
      end)
      |> Enum.map(fn url ->
        """
        curl -O "#{url}"
        """
      end)

    [
      %{
        "guest_path" => "/files.sh",
        "raw_value" => Base.encode64(template <> Enum.join(urls, "\n"))
      }
    ]
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
        if state.type == "assignment_tests" do
          {:ok, presigned_url} =
            ExAws.S3.presigned_url(
              config,
              :put,
              "handin-dev",
              "uploads/assignment/solution/#{assignment_test.id}.out",
              expires_in: 6000
            )

          "curl --request PUT --upload-file \"#{assignment_test.id}.out\" \"#{presigned_url}\""
        else
          {:ok, presigned_url} =
            ExAws.S3.presigned_url(
              config,
              :put,
              "handin-dev",
              "uploads/user/#{state.user_id}/assignment/#{assignment.id}/submission/solution/#{assignment_test.id}.out",
              expires_in: 600
            )

          "curl --request PUT --upload-file \"#{assignment_test.id}.out\" \"#{presigned_url}\""
        end
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
    #!/bin/bash
    output=$(#{assignment_test.command})
    echo "$output" > #{assignment_test.id}.out
    expected_output=#{assignment_test.expected_output_text}
    if [ "$output" = "$expected_output" ]; then
      state="pass"
    else
      state="fail"
    fi
    JSON_FMT='{"state": "%s"}'
    printf "$JSON_FMT" "$state"
    """
  end

  defp get_test_template(assignment_test) do
    """
    #!/bin/bash
    output=$(#{assignment_test.command})
    echo "$output" > #{assignment_test.id}.out
    if diff -wi #{assignment_test.id}.out #{assignment_test.expected_output_file} >/dev/null; then
      state="pass"
    else
      state="fail"
    fi
    JSON_FMT='{"state": "%s"}'
    printf "$JSON_FMT" "$state"
    """
  end
end
