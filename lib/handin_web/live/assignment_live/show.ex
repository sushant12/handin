defmodule HandinWeb.AssignmentLive.Show do
  use HandinWeb, :live_view

  alias Handin.Assignments
  alias Handin.Assignments.AssignmentTest
  alias Handin.AssignmentTests
  alias Handin.Assignments.TestSupportFile

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    assignment = Assignments.get_assignment!(assignment_id)

    {:ok,
     socket
     |> assign(:assignment_tests, assignment.assignment_tests)
     |> assign(current_page: :modules)
     |> assign(:module_id, id)
     |> assign(:assignment, assignment)
     |> assign(:selected_assignment_test, nil)}
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
      test_support_files: [%TestSupportFile{}]
    })
  end

  defp apply_action(socket, :upload_test_files, _) do
    socket
    |> assign(:page_title, "Upload File")
    |> assign(:test_support_file, %TestSupportFile{})
  end

  @impl true
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("delete", %{"test_id" => test_id}, socket) do
    assignment_test = AssignmentTests.get_assignment_test!(test_id)
    {:ok, _} = AssignmentTests.delete_assignment_test(assignment_test)

    {:noreply, stream_delete(socket, :assignment_tests, assignment_test)}
  end

  def handle_event("delete", %{"test_support_file_id" => test_support_file_id}, socket) do
    test_support_file = AssignmentTests.get_test_support_file!(test_support_file_id)
    {:ok, _} = AssignmentTests.delete_test_support_file(test_support_file)

    {:noreply, stream_delete(socket, :test_support_files, test_support_file)}
  end

  def handle_event(
        "assignment_test_selected",
        %{"assignment_test_id" => assignment_test_id},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:selected_assignment_test, assignment_test_id)}
  end

  @impl true
  def handle_info(
        {HandinWeb.AssignmentLive.AssignmentTestComponent, {:saved, assignment_test}},
        socket
      ) do
    {:noreply,
     socket |> assign(:assignment_tests, [assignment_test | socket.assigns.assignment_tests])}
  end
end
