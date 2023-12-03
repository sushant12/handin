defmodule Handin.BuildServer do
  use GenServer
  alias Handin.{AssignmentTests, Assignments}
  alias Handin.SupportFileUploader

  @machine_api Application.compile_env(:handin, :machine_api_module)

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: name_for(state))
  end

  def name_for(state) do
    {:global, "build:#{state.type}:#{state.assignment_test_id}"}
  end

  @impl true
  def init(state) do
    {:ok, state, {:continue, :process_build}}
  end

  @impl true
  def handle_continue(:process_build, state) do
    process_build(state)
    {:stop, "finished", state}
  end

  defp process_build(state) do
    assignment_test =
      AssignmentTests.get_assignment_test!(state.assignment_test_id)

    assignment = assignment_test.assignment

    {:ok, build} =
      Assignments.new_build(%{
        assignment_test_id: assignment_test.id,
        assignment_id: assignment.id,
        status: :running
      })

    log_and_broadcast(build, "Setting up environment...", state)

    case @machine_api.create(
           Jason.encode!(%{
             config: %{
               auto_destroy: true,
               image: state.image,
               files: build_files(assignment)
             }
           })
         ) do
      {:ok, machine} ->
        if machine_started?(machine) do
          Assignments.update_build(build, %{
            machine_id: machine["id"]
          })

          log_and_broadcast(build, "Environment setup completed.", state)

          log_and_broadcast(build, "#{assignment_test.command}.", state)

          case @machine_api.exec(machine["id"], assignment_test.command) do
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

          case @machine_api.stop(machine["id"]) do
            {:ok, _} ->
              Assignments.update_build(build, %{status: :completed})
              log_and_broadcast(build, "Completed!!", state)

            {:error, reason} ->
              Assignments.update_build(build, %{status: :failed})

              log_and_broadcast(build, "Failed to stop machine: #{reason}", state)
          end
        end

      {:error, reason} ->
        Assignments.update_build(build, %{status: :failed})
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

  defp log_and_broadcast(build, message, state) do
    Assignments.log(build.id, message)

    HandinWeb.Endpoint.broadcast!(
      "build:#{state.type}:#{state.assignment_test_id}",
      "new_log",
      build.id
    )
  end

  defp build_files(assignment) do
    (assignment.support_files ++ assignment.solution_files)
    |> Enum.map(fn file ->
      url =
        SupportFileUploader.url({file.file.file_name, file},
          signed: true
        )

      {:ok, %Finch.Response{status: 200, body: body}} =
        Finch.build(:get, url)
        |> Finch.request(Handin.Finch)

      %{
        "guest_path" => "/#{file.file.file_name}",
        "raw_value" => Base.encode64(body)
      }
    end)
  end
end
