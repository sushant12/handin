defmodule HandinWeb.AssignmentLive.Show do
  use HandinWeb, :live_view

  alias Handin.Assignments
  alias Handin.Assignments.AssignmentTest
  alias Handin.AssignmentTests
  alias Handin.AssignmentSubmissions
  alias Handin.Assignments.{TestSupportFile, Command}
  alias Handin.AssignmentSubmission.AssignmentSubmission

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
     |> assign(
       :assignment_submission,
       AssignmentSubmissions.get_user_assignment_submission(socket.assigns.current_user.id)
     )
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

  defp apply_action(socket, :upload_submissions, %{"assignment_id" => assignment_id}) do
    socket
    |> assign(:page_title, "Upload Submissions")
    |> assign(:assignment_submission, %AssignmentSubmission{
      user_id: socket.assigns.current_user.id,
      assignment_id: assignment_id
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
     |> assign(:logs, AssignmentTests.get_recent_build_logs(assignment_test_id) || [])}
  end

  def handle_event("run-test", %{"test_id" => assignment_test_id}, socket) do
    HandinWeb.Endpoint.subscribe("build:assignment_test:#{assignment_test_id}")

    DynamicSupervisor.start_child(Handin.BuildSupervisor, %{
      id: Handin.BuildServer,
      start:
        {Handin.BuildServer, :start_link,
         [
           %{
             assignment_test_id: assignment_test_id,
             type: "assignment_test",
             image: socket.assigns.assignment.programming_language.docker_file_url
           }
         ]},
      restart: :temporary
    })

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
        {HandinWeb.AssignmentSubmission.AssignmentUploadComponent, {:saved, _assignment_test}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(
       :assignment_submission,
       AssignmentSubmissions.get_user_assignment_submission(socket.assigns.current_user.id)
     )}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{event: "new_log", payload: build_id},
        socket
      ) do
    {:noreply, assign(socket, :logs, AssignmentTests.get_logs(build_id))}
  end
end
