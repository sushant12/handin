defmodule HandinWeb.AssignmentLive.Show do
  use HandinWeb, :live_view

  alias Handin.Assignments
  alias Handin.Assignments.AssignmentTest
  alias Handin.AssignmentTests
  alias Handin.AssignmentSubmission.AssignmentSubmission

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    assignment = Assignments.get_assignment!(assignment_id)

    logs = []

    {:ok,
     socket
     |> assign(:assignment_tests, assignment.assignment_tests)
     |> assign(current_page: :modules)
     |> assign(:module_id, id)
     |> assign(:available_tests, nil)
     |> assign(:assignment, assignment)
     |> assign(:selected_assignment_test, nil)
     |> assign(
       :assignment_submission,
       []
     )
     |> assign(:logs, logs)
     |> assign(
       :submitted_assignment_submissions, []
     )
     |> assign(:support_files, [])
     |> assign(:solution_files, [])}
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _), do: socket

  defp apply_action(socket, :add_assignment_test, %{"assignment_id" => assignment_id}) do
    socket
    |> assign(
      :available_tests,
      AssignmentTests.list_assignment_tests_for_assignment(assignment_id)
      |> Enum.map(&{&1.name, &1.id})
    )
    |> assign(:page_title, "Add Test")
    |> assign(:assignment_test, %AssignmentTest{
      assignment_id: assignment_id
    })
  end

  defp apply_action(socket, :upload_submissions, %{"assignment_id" => assignment_id}) do
    socket
    |> assign(:page_title, "Upload Submissions")
    |> assign(:assignment_submission_schema, %AssignmentSubmission{
      user_id: socket.assigns.current_user.id,
      assignment_id: assignment_id
    })
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

  def handle_event("delete", %{"support_file_id" => support_file_id}, socket) do
    support_file = Assignments.get_support_file!(support_file_id)
    {:ok, _} = Assignments.delete_support_file(support_file)

    assignment = Assignments.get_assignment!(socket.assigns.assignment.id)

    {:noreply, socket |> assign(:assignment_tests, assignment.assignment_tests)}
  end

  def handle_event("delete", %{"solution_file_id" => solution_file_id}, socket) do
    solution_file = Assignments.get_solution_file!(solution_file_id)
    {:ok, _} = Assignments.delete_solution_file(solution_file)

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
     |> assign(:selected_assignment_test, assignment_test_id)}
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
        {HandinWeb.AssignmentSubmission.AssignmentUploadComponent, {:saved, _assignment_test}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(
       :assignment_submission,
       []
     )}
  end
end
