defmodule HandinWeb.AssignmentTestLive.Index do
  use HandinWeb, :live_view

  alias Handin.AssignmentTests
  alias Handin.AssignmentTests.AssignmentTest

  @impl true
  def mount(%{"id" => module_id, "assignment_id" => assignment_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:module_id, module_id)
     |> assign(:assignment_id, assignment_id)
     |> stream(
       :assignment_tests,
       AssignmentTests.list_assignment_tests_for_assignment(assignment_id)
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"test_id" => test_id}) do
    socket
    |> assign(:page_title, "Edit Assignment test")
    |> assign(:assignment_test, AssignmentTests.get_assignment_test!(test_id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Assignment test")
    |> assign(:assignment_test, %AssignmentTest{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Assignment tests")
    |> assign(:assignment_test, nil)
  end

  @impl true
  def handle_info({HandinWeb.AssignmentTestLive.FormComponent, {:saved, assignment_test}}, socket) do
    {:noreply, stream_insert(socket, :assignment_tests, assignment_test)}
  end

  @impl true
  def handle_event("delete", %{"test_id" => test_id}, socket) do
    assignment_test = AssignmentTests.get_assignment_test!(test_id)
    {:ok, _} = AssignmentTests.delete_assignment_test(assignment_test)

    {:noreply, stream_delete(socket, :assignment_tests, assignment_test)}
  end
end
