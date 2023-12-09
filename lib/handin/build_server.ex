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
    {:ok, state, {:continue, :process_build}}
  end

  @impl true
  def handle_continue(:process_build, state) do
    process_build(state)

    {:stop, "Server terminated gracefully", state}
  end

  @impl true
  def terminate(_reason, state) do
    state
  end

  @impl true
  def handle_info({:EXIT, _pid, reason}, state) do
    {:stop, reason, state}
  end

  defp process_build(state) do
    assignment =
      Assignments.get_assignment!(state.assignment_id)

    {:ok, build} =
      Assignments.new_build(%{
        assignment_id: assignment.id,
        status: :running
      })

    with {:ok, machine} <-
           @machine_api.create(
             Jason.encode!(%{
               config: %{
                 auto_destroy: true,
                 image: state.image,
                 files:
                   build_files(assignment, state.type) ++
                     build_main_script(assignment) ++ build_tests_scripts(assignment)
               }
             })
           ),
         true <- machine_started?(machine),
         {:ok, build} <- Assignments.update_build(build, %{machine_id: machine["id"]}),
         {:ok, %{"exit_code" => 0} = response} <- @machine_api.exec(machine["id"], "sh ./main.sh") do
      log_and_broadcast(build, "sh ./main.sh", response["stdout"], state)

      assignment.assignment_tests
      |> Enum.map(&{"#{&1.name}_#{&1.id}.sh", &1})
      |> Enum.each(fn {file_name, assignment_test} ->
        case @machine_api.exec(machine["id"], "sh ./#{file_name}") do
          {:ok, %{"exit_code" => 0} = response} ->
            log_and_broadcast(build, assignment_test.id, response["stdout"], state)

          {:ok, %{"exit_code" => 1} = response} ->
            log_and_broadcast(build, assignment_test.id, response["stderr"], state)

          {:error, reason} ->
            log_and_broadcast(build, assignment_test.id, reason, state)
        end
      end)

      {:ok, _} =
        @machine_api.stop(machine["id"])

      Assignments.update_build(build, %{status: :completed})
    else
      {:error, reason} ->
        Assignments.update_build(build, %{status: :failed})
        log_and_broadcast(build, "", reason, state)

      {:ok, %{"exit_code" => 1} = reason} ->
        Assignments.update_build(build, %{status: :failed})
        log_and_broadcast(build, "", reason, state)
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

  defp log_and_broadcast(build, test_id, message, state) do
    Assignments.log(build.id, test_id, message)

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

  # defp compare_output(_assignment_test, _response) do
  #   "PASS"
  #   # if assignment_test.expected_output_type == "text" do
  #   #   if response["stdout"] == assignment_test.expected_output_text, do: "PASS", else: "FAIL"
  #   # else
  #   #   url =
  #   #     SupportFileUploader.url({assignment_test.expected_output_file, Assignments.get_support_file_by_name!(assignment, assignment_test.expected_output_file)},
  #   #     signed: true
  #   #     )

  #   #   {:ok, %Finch.Response{status: 200, body: body}} =
  #   #     Finch.build(:get, url)
  #   #     |> Finch.request(Handin.Finch)

  #   #   # response body has \n. need to strip them
  #   #   if response["stdout"] == body, do: "PASS", else: "FAIL"
  #   # end
  # end
end
