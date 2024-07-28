defmodule Handin.BuildServer do
  use GenServer
  alias Handin.Assignments
  alias Handin.{SupportFileUploader, AssignmentSubmissionFileUploader}
  alias Handin.AssignmentSubmission.AssignmentSubmissionFile

  @machine_api Application.compile_env(:handin, :machine_api_module)

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: name_for(state))
  end

  def name_for(state) do
    if state.type == "assignment_tests" do
      {:global, "build:#{state.type}:#{state.assignment_id}"}
    else
      {:global, "build:#{state.type}:#{state.assignment_submission_id}"}
    end
  end

  @impl true
  def init(state) do
    assignment = Assignments.get_assignment!(state.assignment_id)
    {:ok, build} = Assignments.new_build(%{
      assignment_id: assignment.id,
      status: :running,
      user_id: state.user_id
    })
    state = state |> Map.put(:assignment, assignment) |> Map.put(:build, build)
    {:ok, state, {:continue, :create_machine}}
  end

  @impl true
  def handle_continue(:create_machine, state) do
    case create_machine(state) do
      {:ok, _machine, state} ->
        {:noreply, state, {:continue, :process_build}}
      {:error, reason} ->
        Assignments.update_build(state.build, %{status: :failed})
        {:stop, reason, state}
    end
  end

  @impl true
  def handle_continue(:process_build, state) do
    case process_build_steps(state) do
      {:ok, state} -> finalize_build(state)
      {:error, state} -> handle_build_error(state)
    end
  end

  defp create_machine(state) do
    machine_config = %{
      config: %{
        init: %{exec: ["/bin/sleep", "inf"]},
        auto_destroy: true,
        image: state.image,
        files: build_scripts(state)
      }
    }

    with {:ok, machine} <- @machine_api.create(Jason.encode!(machine_config)),
         true <- machine_started?(machine),
         {:ok, build} <- Assignments.update_build(state.build, %{machine_id: machine["id"]}) do
      {:ok, machine, %{state | machine_id: machine["id"], build: build}}
    else
      _ -> {:error, "Failed To Create Container"}
    end
  end

  defp build_scripts(state) do
    build_main_script(state.assignment) ++
    build_file_download_script(state.assignment, state.type, state.user_id) ++
    build_upload_script(state.assignment, state) ++
    build_check_script(state.assignment) ++
    build_tests_scripts(state.assignment)
  end

  defp process_build_steps(state) do
    with {:ok, state} <- run_files_script(state),
         {:ok, state} <- run_main_script(state),
         {:ok, state} <- process_assignment_tests(state) do
      {:ok, state}
    else
      {:error, state} -> {:error, state}
    end
  end

  defp run_files_script(state) do
    case @machine_api.exec(state.machine_id, "sh ./files.sh") do
      {:ok, %{"exit_code" => 0}} -> {:ok, state}
      _ -> {:error, update_build_status(state, :failed)}
    end
  end

  defp run_main_script(state) do
    case @machine_api.exec(state.machine_id, "sh ./main.sh") do
      {:ok, %{"exit_code" => 0} = response} ->
        state = save_run_script_results(state, :pass)
        log_and_broadcast(state.build, %{command: "sh ./main.sh", output: response["stdout"]}, state)
        {:ok, state}
      {:ok, reason} ->
        state = save_run_script_results(state, :fail)
        log_and_broadcast(state.build, %{command: "sh ./main.sh", output: reason["stderr"]}, state)
        {:error, update_build_status(state, :failed)}
    end
  end

  defp process_assignment_tests(state) do
    Enum.reduce_while(state.assignment.assignment_tests, {:ok, state}, fn assignment_test, {:ok, acc_state} ->
      case process_single_test(acc_state, assignment_test) do
        {:ok, new_state} -> {:cont, {:ok, new_state}}
        {:error, new_state} -> {:halt, {:error, new_state}}
      end
    end)
  end

  defp process_single_test(state, assignment_test) do
    file_name = "#{assignment_test.id}.sh"
    case @machine_api.exec(state.machine_id, "sh ./#{file_name}") do
      {:ok, %{"exit_code" => 0} = response} -> handle_successful_test(state, assignment_test, response)
      {:ok, response} -> handle_failed_test(state, assignment_test, response)
      {:error, reason} -> handle_test_error(state, assignment_test, reason)
    end
  end

  defp handle_successful_test(state, assignment_test, response) do
    :timer.sleep(3000)
    case Jason.decode(response["stdout"]) do
      {:ok, decoded_response} -> save_and_log_test_results(state, assignment_test, decoded_response)
      {:error, _} -> handle_json_parse_error(state, assignment_test)
    end
  end

  defp handle_failed_test(state, assignment_test, response) do
    save_test_results(state, assignment_test, :fail)
    log_and_broadcast(state.build, %{
      command: assignment_test.command,
      assignment_test_id: assignment_test.id,
      output: response["stderr"]
    }, state)
    {:ok, state}
  end

  defp handle_test_error(state, assignment_test, reason) do
    save_test_results(state, assignment_test, :fail)
    log_and_broadcast(state.build, %{
      command: assignment_test.command,
      assignment_test_id: assignment_test.id,
      output: reason
    }, state)
    {:ok, state}
  end

  defp save_and_log_test_results(state, assignment_test, response) do
    test_state = if response["state"] == "pass", do: :pass, else: :fail
    save_test_results(state, assignment_test, test_state)
    log_and_broadcast(state.build, %{
      command: assignment_test.command,
      assignment_test_id: assignment_test.id,
      output: response["output"],
      expected_output: response["expected_output"]
    }, state)
    {:ok, state}
  end

  defp handle_json_parse_error(state, assignment_test) do
    save_test_results(state, assignment_test, :fail)
    log_and_broadcast(state.build, %{
      command: assignment_test.command,
      assignment_test_id: assignment_test.id,
      output: "Error parsing JSON response"
    }, state)
    {:ok, state}
  end

  defp save_test_results(state, assignment_test, test_state) do
    Assignments.save_test_results(%{
      assignment_test_id: assignment_test.id,
      state: test_state,
      build_id: state.build.id,
      user_id: state.user_id
    })
  end

  defp update_build_status(state, status) do
    {:ok, build} = Assignments.update_build(state.build, %{status: status})
    %{state | build: build}
  end

  defp finalize_build(state) do
    state = update_build_status(state, :completed)
    Assignments.get_logs(state.build.id)
    broadcast_build_completed(state)
    upload_and_stop_machine(state)
    {:stop, :normal, state}
  end

  defp handle_build_error(state) do
    broadcast_build_completed(state)
    upload_and_stop_machine(state)
    {:stop, :normal, state}
  end

  defp broadcast_build_completed(state) do
    if state.type == "assignment_tests" do
      HandinWeb.Endpoint.broadcast!("build:#{state.type}:#{state.assignment_id}", "build_completed", state.build.id)
    else
      Assignments.submit_assignment(state.assignment_submission_id, state.assignment.enable_max_attempts)
      submission = Assignments.get_submission(state.assignment.id, state.user_id)
      Assignments.evaluate_marks(submission.id, state.build.id)
      HandinWeb.Endpoint.broadcast("build:#{state.type}:#{state.assignment_submission_id}", "build_completed", state.build.id)
    end
  end

  defp upload_and_stop_machine(state) do
    @machine_api.exec(state.machine_id, "sh ./upload.sh")
    @machine_api.stop(state.machine_id)
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

  defp log_and_broadcast(build, log_map, state) do
    log_map = log_map |> Map.put(:build_id, build.id)
    Assignments.log(log_map)
    channel = if state.type == "assignment_tests", do: state.assignment_id, else: state.assignment_submission_id
    HandinWeb.Endpoint.broadcast!("build:#{state.type}:#{channel}", "test_result", build.id)
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

  defp build_file_download_script(assignment, type, user_id) do
    template = "#!bin/bash\n"
    assignment_files = get_assignment_files(assignment, type, user_id)
    urls = Enum.map(assignment_files, &get_file_url/1)
    curl_commands = Enum.map(urls, fn url -> "curl -O \"#{url}\"\n" end)
    [
      %{
        "guest_path" => "/files.sh",
        "raw_value" => Base.encode64(template <> Enum.join(curl_commands))
      }
    ]
  end

  defp get_assignment_files(assignment, type, user_id) do
    if type == "assignment_tests" do
      assignment.support_files ++ assignment.solution_files
    else
      assignment.support_files ++ Assignments.get_submission_files(assignment.id, user_id)
    end
  end

  defp get_file_url(file) do
    case file do
      %AssignmentSubmissionFile{} = file ->
        AssignmentSubmissionFileUploader.url({file.file.file_name, file}, signed: true)
      _ ->
        SupportFileUploader.url({file.file.file_name, file}, signed: true)
    end
  end

  defp build_main_script(assignment) do
    [
      %{
        "guest_path" => "/main.sh",
        "raw_value" => Base.encode64("#!bin/bash\n#{assignment.run_script}")
      }
    ]
  end

  defp build_upload_script(assignment, state) do
    config = ExAws.Config.new(:s3, Application.get_all_env(:ex_aws))
    template = "#!/bin/bash\n"
    curls = Enum.map(assignment.assignment_tests, &build_curl_command(&1, state, config))
    [
      %{
        "guest_path" => "/upload.sh",
        "raw_value" => Base.encode64(template <> Enum.join(curls, "\n"))
      }
    ]
  end

  defp build_curl_command(assignment_test, state, config) do
    {:ok, presigned_url} = get_presigned_url(state, assignment_test, config)
    "curl --request PUT --upload-file \"#{assignment_test.id}.out\" \"#{presigned_url}\""
  end

  defp get_presigned_url(state, assignment_test, config) do
    bucket = "handin-dev"
    key = if state.type == "assignment_tests" do
      "uploads/assignment/solution/#{assignment_test.id}.out"
    else
      "uploads/user/#{state.user_id}/assignment/#{state.assignment.id}/submission/solution/#{assignment_test.id}.out"
    end
    ExAws.S3.presigned_url(config, :put, bucket, key, expires_in: 6000)
  end

  defp build_tests_scripts(assignment) do
    Enum.map(assignment.assignment_tests, &build_single_test_script/1)
  end

  defp build_single_test_script(assignment_test) do
    template = if assignment_test.enable_custom_test do
      assignment_test.custom_test
    else
      build_default_test_script(assignment_test)
    end
    %{
      "guest_path" => "/#{assignment_test.id}.sh",
      "raw_value" => Base.encode64(template)
    }
  end

  defp build_default_test_script(assignment_test) do
    if assignment_test.expected_output_type == :string do
      build_string_comparison_script(assignment_test)
    else
      build_file_comparison_script(assignment_test)
    end
  end

  defp build_string_comparison_script(assignment_test) do
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

  defp build_file_comparison_script(assignment_test) do
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

  defp save_run_script_results(state, result) do
    Assignments.save_run_script_results(%{
      build_id: state.build.id,
      user_id: state.user_id,
      result: result
    })
    state
  end
end
