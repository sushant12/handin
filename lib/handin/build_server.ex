defmodule Handin.BuildServer do
  use GenServer
  alias Handin.AssignmentTests

  @machine_api Application.compile_env(:handin, :machine_api_module)

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: name_for(state))
  end

  def name_for(state), do: {:global, "build:#{state.type}:#{state.assignment_test_id}"}

  @impl true
  def init(state) do
    process_build(state)

    {:stop, "finished"}
  end

  defp process_build(state) do
    assignment_test = AssignmentTests.get_assignment_test!(state.assignment_test_id)

    {:ok, build} =
      AssignmentTests.new_build(%{
        assignment_test_id: assignment_test.id,
        status: "environment_setup"
      })

    log_and_broadcast(build, "Setting up environment...", state)

    case @machine_api.create(
           Jason.encode!(%{
             config: %{
               image: state.image
               # files: build_files(socket.assigns.assignment)
             }
           })
         ) do
      {:ok, machine} ->
        AssignmentTests.update_build(build, %{machine_id: machine["id"], status: "setup_complete"})

        log_and_broadcast(build, "Environment setup completed.", state)
        AssignmentTests.update_build(build, %{status: "execute_command"})

        assignment_test.commands
        |> Enum.each(fn %{command: command} ->
          log_and_broadcast(build, "Running command #{command}.", state)

          case @machine_api.exec(machine["id"], command) do
            {:ok, response} ->
              log_and_broadcast(build, response["stdout"], state)

            {:error, reason} ->
              log_and_broadcast(build, "Failed: #{reason}", state)
          end
        end)

        AssignmentTests.update_build(build, %{status: "execute_command_complete"})

        case @machine_api.stop(machine["id"]) do
          {:ok, _} ->
            AssignmentTests.update_build(build, %{status: "machine_stopped"})

            case @machine_api.destroy(machine["id"]) do
              {:ok, _} ->
                AssignmentTests.update_build(build, %{status: "machine_destroyed"})
                log_and_broadcast(build, "Completed!!", state)
                AssignmentTests.update_build(build, %{status: "completed"})

              {:error, reason} ->
                AssignmentTests.update_build(build, %{status: "machine_destroy_failed"})

                log_and_broadcast(build, "Failed to stop machine: #{reason}", state)
            end

          {:error, reason} ->
            AssignmentTests.update_build(build, %{status: "machine_stopped_failed"})

            log_and_broadcast(build, "Failed to stop machine: #{reason}", state)
        end

      {:error, reason} ->
        AssignmentTests.update_build(build, %{status: "setup_failed"})
        log_and_broadcast(build, "Failed to setup VM: #{reason}", state)
    end
  end

  defp log_and_broadcast(build, message, state) do
    AssignmentTests.log(build.id, message)

    HandinWeb.Endpoint.broadcast!(
      "build:#{state.type}:#{state.assignment_test_id}",
      "new_log",
      state.assignment_test_id
    )
  end
end
