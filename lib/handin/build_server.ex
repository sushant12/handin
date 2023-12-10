defmodule Handin.BuildServer do
  use GenServer
  alias Handin.Assignments
  alias Handin.SupportFileUploader

  @machine_api Application.compile_env(:handin, :machine_api_module)

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: name_for(state))
  end

  def name_for(state) do
    {:global, "build:#{state.type}:#{state.assignment_id}"}
  end

  @impl true
  def init(state) do
    assignment = Assignments.get_assignment!(state.assignment_id)

    {:ok, build} =
      Assignments.new_build(%{
        assignment_id: assignment.id,
        status: :running
      })

    state = state |> Map.put(:assignment, assignment) |> Map.put(:build, build)

    {:ok, state, {:continue, :create_machine}}
  end

  @impl true
  def handle_continue(:create_machine, state) do
    with {:ok, machine} <-
           @machine_api.create(
             Jason.encode!(%{
               config: %{
                 auto_destroy: true,
                 image: state.image,
                 files:
                   build_files(state.assignment, state.type) ++
                     build_main_script(state.assignment) ++ build_tests_scripts(state.assignment)
               }
             })
           ),
         true <- machine_started?(machine),
         {:ok, build} <- Assignments.update_build(state.build, %{machine_id: machine["id"]}) do
      state = state |> Map.put(:machine_id, machine["id"]) |> Map.put(:build, build)

      {:noreply, state, {:continue, :process_build}}
    else
      _ ->
        Assignments.update_build(state.build, %{status: :failed})

        {:stop, "Failed To Create Container", state}
    end
  end

  def handle_continue(:process_build, state) do
    with {:ok, %{"exit_code" => 0} = response} <-
           @machine_api.exec(state.machine_id, "sh ./main.sh") do
      # TODO: save to run_script_result table
      log_and_broadcast(
        state.build,
        %{command: "sh ./main.sh", output: response["stdout"]},
        state
      )

      state.assignment.assignment_tests
      |> Enum.map(&{"#{&1.name}_#{&1.id}.sh", &1})
      |> Enum.each(fn {file_name, assignment_test} ->
        case @machine_api.exec(state.machine_id, "sh ./#{file_name}") do
          {:ok, %{"exit_code" => 0} = response} ->
            if match_output?(assignment_test, response["stdout"]) do
              # TODO: save to test_results table as passed
            else
              # TODO: save to test_results table as failed
            end

            log_and_broadcast(
              state.build,
              %{
                command: assignment_test.command,
                assignment_test_id: assignment_test.id,
                output: response["stdout"]
              },
              state
            )

          {:ok, %{"exit_code" => 1} = response} ->
            # TODO: save to test_results table as failed

            log_and_broadcast(
              state.build,
              %{
                command: assignment_test.command,
                assignment_test_id: assignment_test.id,
                output: response["stderr"]
              },
              state
            )

          {:error, reason} ->
            # TODO: save to test_results table as failed

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
      end)

      Assignments.update_build(state.build, %{status: :completed})
    else
      {:ok, %{"exit_code" => 1} = reason} ->
        Assignments.update_build(state.build, %{status: :failed})
        # TODO: save to run_script_result table

        log_and_broadcast(
          state.build,
          %{command: "sh ./main.sh", output: reason["stderr"]},
          state
        )
    end

    Assignments.get_logs(state.build.id)
    @machine_api.stop(state.machine_id)
    {:stop, "Server terminated gracefully", state}
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

    HandinWeb.Endpoint.broadcast!(
      "build:#{state.type}:#{state.assignment_id}",
      "new_log",
      build.id
    )
  end

  defp build_files(assignment, type) do
    assignment_files =
      if type == "assignment_tests" do
        assignment.support_files ++ assignment.solution_files
      else
        assignment.support_files
      end

    assignment_files
    |> Enum.map(fn assignment_file ->
      url =
        SupportFileUploader.url({assignment_file.file.file_name, assignment_file},
          signed: true
        )

      {:ok, %Finch.Response{status: 200, body: body}} =
        Finch.build(:get, url)
        |> Finch.request(Handin.Finch)

      %{
        "guest_path" => "/#{assignment_file.file.file_name}",
        "raw_value" => Base.encode64(body)
      }
    end)
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

  defp build_tests_scripts(assignment) do
    assignment.assignment_tests
    |> Enum.map(fn assignment_test ->
      template = """
        #!bin/bash
        #{assignment_test.command}
      """

      %{
        "guest_path" => "/#{assignment_test.name}_#{assignment_test.id}.sh",
        "raw_value" => Base.encode64(template)
      }
    end)
  end

  defp match_output?(assignment_test, output) do
    if assignment_test.expected_output_type == "text" do
      output == assignment_test.expected_output_text
    else
      url =
        SupportFileUploader.url(
          {assignment_test.expected_output_file,
           Assignments.get_support_file_by_name!(
             assignment_test.assignment_id,
             assignment_test.expected_output_file
           )},
          signed: true
        )

      {:ok, %Finch.Response{status: 200, body: body}} =
        Finch.build(:get, url)
        |> Finch.request(Handin.Finch)

      output == body
    end
  end
end
