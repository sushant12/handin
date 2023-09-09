defmodule Handin.BuildServer do
  use GenServer
  alias Handin.AssignmentTests
  alias Handin.{TestSupportFileUploader, AssignmentSubmissions, AssignmentSubmissionFileUploader}

  @machine_api Application.compile_env(:handin, :machine_api_module)

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: name_for(state))
  end

  def name_for(state) do
    case state.type do
      "assignment_test" ->
        {:global, "build:#{state.type}:#{state.assignment_test_id}"}

      "assignment_submission" ->
        {:global, "build:#{state.type}:#{state.assignment_submission_id}"}
    end
  end

  @impl true
  def init(state) do
    {:ok, state, {:continue, :process_build}}
  end

  @impl true
  def handle_continue(:process_build, %{type: "assignment_submission"} = state) do
    Enum.each(state.assignment_tests, fn assignment_test ->
      state = Map.put(state, :assignment_test_id, assignment_test.id)
      process_build(state)
    end)

    {:stop, "finished", state}
  end

  def handle_continue(:process_build, state) do
    process_build(state)
    {:stop, "finished", state}
  end

  defp process_build(state) do
    assignment_test =
      AssignmentTests.get_assignment_test!(state.assignment_test_id)

    {:ok, build} =
      AssignmentTests.new_build(%{
        assignment_test_id: assignment_test.id,
        status: "environment_setup"
      })

    log_and_broadcast(build, "Setting up environment...", state)

    build_files =
      case state.type do
        "assignment_test" ->
          %{test: assignment_test}

        "assignment_submission" ->
          AssignmentTests.add_assignment_submission_build_record(%{
            build_id: build.id,
            assignment_submission_id: state.assignment_submission_id
          })

          %{assignment_submission_id: state.assignment_submission_id}
      end
      |> build_files()

    case @machine_api.create(
           Jason.encode!(%{
             config: %{
               auto_destroy: true,
               image: state.image,
               files: build_files
             }
           })
         ) do
      {:ok, machine} ->
        if machine_started?(machine) do
          AssignmentTests.update_build(build, %{
            machine_id: machine["id"],
            status: "setup_complete"
          })

          log_and_broadcast(build, "Environment setup completed.", state)
          AssignmentTests.update_build(build, %{status: "execute_command"})

          assignment_test.commands
          |> Enum.each(fn %{name: name, command: command} ->
            log_and_broadcast(build, "#{name} #{command}.", state)

            case @machine_api.exec(machine["id"], command) do
              {:ok, response} ->
                message =
                  if String.trim(response["stdout"]) == "" do
                    response["stderr"]
                  else
                    response["stdout"]
                  end

                log_and_broadcast(build, message, state)

              {:error, reason} ->
                log_and_broadcast(build, "Failed: #{reason}", state)
            end
          end)

          AssignmentTests.update_build(build, %{status: "execute_command_complete"})

          case @machine_api.stop(machine["id"]) do
            {:ok, _} ->
              AssignmentTests.update_build(build, %{status: "machine_stopped"})
              log_and_broadcast(build, "Completed!!", state)
              AssignmentTests.update_build(build, %{status: "completed"})

            {:error, reason} ->
              AssignmentTests.update_build(build, %{status: "machine_stopped_failed"})

              log_and_broadcast(build, "Failed to stop machine: #{reason}", state)
          end
        end

      {:error, reason} ->
        AssignmentTests.update_build(build, %{status: "setup_failed"})
        log_and_broadcast(build, "Failed to setup VM: #{reason}", state)
    end
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

  defp log_and_broadcast(build, message, %{type: "assignment_test"} = state) do
    AssignmentTests.log(build.id, message)

    HandinWeb.Endpoint.broadcast!(
      "build:#{state.type}:#{state.assignment_test_id}",
      "new_log",
      build.id
    )
  end

  defp log_and_broadcast(build, message, %{type: "assignment_submission"} = state) do
    AssignmentTests.log(build.id, message)

    HandinWeb.Endpoint.broadcast!(
      "build:#{state.type}:#{state.assignment_submission_id}",
      "new_assignment_submission_log",
      build.id
    )
  end

  defp build_files(%{test: assignment_test}) do
    assignment_test.test_support_files
    |> Enum.map(fn test_support_file ->
      url =
        TestSupportFileUploader.url({test_support_file.file.file_name, test_support_file},
          signed: true
        )

      {:ok, %Finch.Response{status: 200, body: body}} =
        Finch.build(:get, url)
        |> Finch.request(Handin.Finch)

      %{
        "guest_path" => "/#{test_support_file.file.file_name}",
        "raw_value" => Base.encode64(body)
      }
    end)
  end

  defp build_files(%{assignment_submission_id: assignment_submission_id}) do
    assignment_submission =
      AssignmentSubmissions.get_assignment_submission!(assignment_submission_id)

    assignment_submission.assignment_submission_files
    |> Enum.map(fn submission_file ->
      url =
        AssignmentSubmissionFileUploader.url({submission_file.file.file_name, submission_file},
          signed: true
        )

      {:ok, %Finch.Response{status: 200, body: body}} =
        Finch.build(:get, url)
        |> Finch.request(Handin.Finch)

      %{
        "guest_path" => "/#{submission_file.file.file_name}",
        "raw_value" => Base.encode64(body)
      }
    end)
  end
end
