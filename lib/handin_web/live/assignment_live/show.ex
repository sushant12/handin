defmodule HandinWeb.AssignmentLive.Show do
  use HandinWeb, :live_view

  alias Handin.Assignments
  alias Handin.Assignments.AssignmentTest
  alias Handin.AssignmentTests
  alias Handin.Assignments.{TestSupportFile, Command}
  alias Handin.MachineApi
  alias Handin.TestSupportFileUploader, as: Uploader

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    assignment = Assignments.get_assignment!(assignment_id)

    {:ok,
     socket
     |> assign(:assignment_tests, assignment.assignment_tests)
     |> assign(current_page: :modules)
     |> assign(:module_id, id)
     |> assign(:assignment, assignment)
     |> assign(:selected_assignment_test, nil)
     |> assign(:logs, [])}
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _), do: socket

  defp apply_action(socket, :add_assignment_test, %{"assignment_id" => assignment_id}) do
    socket
    |> assign(:page_title, "Add Test")
    |> assign(:assignment_test, %AssignmentTest{
      assignment_id: assignment_id,
      commands: [%Command{}],
      test_support_files: [%TestSupportFile{}]
    })
  end

  defp apply_action(socket, :upload_test_files, _) do
    socket
    |> assign(:page_title, "Upload File")
    |> assign(:test_support_file, %TestSupportFile{})
  end

  defp apply_action(socket, :edit_assignment_test, %{"test_id" => test_id}) do
    socket
    |> assign(:page_title, "Edit Test")
    |> assign(:assignment_test, AssignmentTests.get_assignment_test!(test_id))
  end

  @impl true
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("delete", %{"test_id" => test_id}, socket) do
    assignment_test = AssignmentTests.get_assignment_test!(test_id)
    {:ok, _} = AssignmentTests.delete_assignment_test(assignment_test)

    assignment_tests =
      Enum.filter(socket.assigns.assignment_tests, fn test -> test.id != assignment_test.id end)

    {:noreply, assign(socket, :assignment_tests, assignment_tests)}
  end

  def handle_event("delete", %{"test_support_file_id" => test_support_file_id}, socket) do
    test_support_file = AssignmentTests.get_test_support_file!(test_support_file_id)
    {:ok, _} = AssignmentTests.delete_test_support_file(test_support_file)

    assignment = Assignments.get_assignment!(socket.assigns.assignment.id)

    {:noreply, socket |> assign(:assignment_tests, assignment.assignment_tests)}
  end

  def handle_event(
        "assignment_test_selected",
        %{"assignment_test_id" => assignment_test_id},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:selected_assignment_test, assignment_test_id)
     |> assign(:logs, AssignmentTests.get_logs(assignment_test_id) || [])}
  end

  def handle_event("run-test", %{"test_id" => test_id}, socket) do
    assignment_test = AssignmentTests.get_assignment_test!(test_id)
    HandinWeb.Endpoint.subscribe("test:#{test_id}")
    {:ok, build} = AssignmentTests.new_build(test_id)
    AssignmentTests.log(build.id, "Setting up environment...")
    HandinWeb.Endpoint.broadcast!("test:#{test_id}", "new_log", test_id)

    {:ok, machine} =
      MachineApi.create(
        Jason.encode!(%{
          config: %{
            image: socket.assigns.assignment.programming_language.docker_file_url,
            files: build_files(assignment_test)
          }
        })
      )

    AssignmentTests.update_build(build, %{machine_id: machine["id"]})
    AssignmentTests.log(build.id, "Environment setup completed...")

    assignment_test.commands
    |> Enum.each(fn command ->
      AssignmentTests.log(build.id, "Executing command #{command}")

      case MachineApi.exec(machine["id"], command) do
        {:ok, response} ->
          AssignmentTests.log(build.id, response["stdout"])
      end
    end)

    MachineApi.stop(machine["id"])
    MachineApi.destroy(machine["id"])
    AssignmentTests.log(build.id, "Completed!!")
    HandinWeb.Endpoint.broadcast!("test:#{test_id}", "new_log", test_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info(
        {HandinWeb.AssignmentLive.AssignmentTestComponent, {:saved, _assignment_test}},
        socket
      ) do
    assignment = Assignments.get_assignment!(socket.assigns.assignment.id)

    {:noreply, socket |> assign(:assignment_tests, assignment.assignment_tests)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{event: "new_log", payload: assignment_test_id},
        socket
      ) do
    {:noreply, assign(socket, :logs, AssignmentTests.get_logs(assignment_test_id))}
  end

  defp build_files(assignment_test) do
    AssignmentTests.get_test_support_files_for_test(assignment_test.id)
    |> Enum.map(fn test_support_file ->
      %HTTPoison.Response{body: body} =
        Uploader.url({test_support_file.file.filename, assignment_test}, signed: true)
        |> HTTPoison.get!()

      encoded_body =
        body
        |> Base.encode64()

      %{"guest_path" => "#{test_support_file.file.filename}", "raw_value" => encoded_body}
    end)
  end
end
