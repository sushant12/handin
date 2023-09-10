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

    logs =
      if socket.assigns.current_user.role == "student" do
        assignment_submission =
          AssignmentSubmissions.get_user_assignment_submission(
            socket.assigns.current_user.id,
            assignment.id
          )

        if assignment_submission do
          logs(assignment_submission)
        else
          []
        end
      else
        []
      end

    {:ok,
     socket
     |> assign(:assignment_tests, assignment.assignment_tests)
     |> assign(current_page: :modules)
     |> assign(:module_id, id)
     |> assign(:assignment, assignment)
     |> assign(:selected_assignment_test, nil)
     |> assign(
       :assignment_submission,
       AssignmentSubmissions.get_user_assignment_submission(
         socket.assigns.current_user.id,
         assignment.id
       )
     )
     |> assign(:logs, logs)}
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
    |> assign(:assignment_submission_schema, %AssignmentSubmission{
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
        "delete",
        %{"assignment_submission_file_id" => assignment_submission_file_id},
        socket
      ) do
    assignment_submission_file =
      AssignmentSubmissions.get_assignment_submission_file!(assignment_submission_file_id)

    AssignmentSubmissions.delete_assignment_submission_file!(assignment_submission_file)
    assignment = Assignments.get_assignment!(socket.assigns.assignment.id)


    {:noreply,
     socket
     |> assign(
       :assignment_submission,
       AssignmentSubmissions.get_user_assignment_submission(
         socket.assigns.current_user.id,
         assignment.id
       )
     )}
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

  def handle_event(
        "submit-assignment",
        %{"assignment_submission_id" => assignment_submission_id},
        socket
      ) do
    if socket.assigns.assignment.max_attempts >= socket.assigns.assignment_submission.retries do
      AssignmentSubmissions.soft_delete_old_builds(assignment_submission_id)
      HandinWeb.Endpoint.subscribe("build:assignment_submission:#{assignment_submission_id}")

      DynamicSupervisor.start_child(Handin.BuildSupervisor, %{
        id: Handin.AssignmentBuildServer,
        start:
          {Handin.AssignmentBuildServer, :start_link,
           [
             %{
               type: "assignment_submission",
               image: socket.assigns.assignment.programming_language.docker_file_url,
               assignment_submission_id: assignment_submission_id,
               assignment_tests: socket.assigns.assignment_tests
             }
           ]},
        restart: :temporary
      })
    end

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
       AssignmentSubmissions.get_user_assignment_submission(
         socket.assigns.current_user.id,
         socket.assigns.assignment.id
       )
     )}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{event: "new_log", payload: build_id},
        socket
      ) do
    {:noreply, assign(socket, :logs, AssignmentTests.get_logs(build_id))}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "new_assignment_submission_log",
          payload: _assignment_submission_id
        },
        socket
      ) do
    {:noreply, assign(socket, :logs, logs(socket.assigns.assignment_submission))}
  end

  defp logs(assignment_submission) do
    AssignmentSubmissions.get_builds(assignment_submission.id)
    |> Enum.map(fn assignment_submission_build ->
      assignment_submission_build.build.logs
      |> Enum.sort(&(DateTime.compare(&1.updated_at, &2.updated_at) != :gt))
    end)
    |> List.flatten()
  end
end
