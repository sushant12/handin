defmodule HandinWeb.AssignmentSubmissionLive.Show do
  use HandinWeb, :live_view

  alias Handin.AssignmentSubmissions
  alias Handin.Assignments
  alias Handin.AssignmentSubmissionFileUploader

  @impl true
  def mount(
        %{
          "assignment_id" => assignment_id,
          "submission_id" => submission_id
        },
        _session,
        socket
      ) do
    assignment = Assignments.get_assignment!(assignment_id)

    {:ok,
     socket
     |> assign(
       :assignment_submission,
       AssignmentSubmissions.get_assignment_submission!(submission_id)
     )
     |> assign(:logs, [])
     |> assign(:assignment, assignment)
     |> assign(:assignment_tests, assignment.assignment_tests)
     |> assign(:selected_assignment_submission_file, nil)}
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _), do: socket

  @impl true
  def handle_event(
        "run-tests",
        %{"assignment_submission_id" => assignment_submission_id},
        socket
      ) do
    AssignmentSubmissions.soft_delete_old_lecturer_builds(assignment_submission_id)

    HandinWeb.Endpoint.subscribe(
      "build:lecturer_assignment_submission_test:#{assignment_submission_id}"
    )

    DynamicSupervisor.start_child(Handin.BuildSupervisor, %{
      id: Handin.LecturerAssignmentBuildServer,
      start:
        {Handin.LecturerAssignmentBuildServer, :start_link,
         [
           %{
             type: "lecturer_assignment_submission_test",
             image: socket.assigns.assignment.programming_language.docker_file_url,
             assignment_submission_id: assignment_submission_id,
             assignment_tests: socket.assigns.assignment_tests
           }
         ]},
      restart: :temporary
    })

    {:noreply, socket}
  end

  def handle_event(
        "assignment_submission_file_selected",
        %{"assignment_submission_file_id" => assignment_submission_file_id},
        socket
      ) do
    submission_file =
      AssignmentSubmissions.get_assignment_submission_file!(assignment_submission_file_id)

    url =
      AssignmentSubmissionFileUploader.url({submission_file.file.file_name, submission_file},
        signed: true
      )

    {:ok, %Finch.Response{status: 200, body: body}} =
      Finch.build(:get, url)
      |> Finch.request(Handin.Finch)

    {:noreply,
     socket
     |> assign(:selected_assignment_submission_file, assignment_submission_file_id)
     |> LiveMonacoEditor.set_value(body)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "new_lecturer_assignment_submission_log",
          payload: _assignment_submission_id
        },
        socket
      ) do
    {:noreply, assign(socket, :logs, logs(socket.assigns.assignment_submission))}
  end

  defp logs(assignment_submission) do
    AssignmentSubmissions.get_lecturer_builds(assignment_submission.id)
    |> Enum.map(fn assignment_submission_build ->
      assignment_submission_build.build.logs
      |> Enum.sort(&(DateTime.compare(&1.updated_at, &2.updated_at) != :gt))
    end)
    |> List.flatten()
  end
end
