defmodule HandinWeb.AssignmentSubmissionLive.Show do
  use HandinWeb, :live_view
  import HandinWeb.AssignmentLive.AccordionComponent

  alias Handin.Modules
  alias Handin.Assignments
  alias Handin.AssignmentSubmissions
  alias Handin.AssignmentSubmissionFileUploader

  @impl true
  def render(assigns) do
    ~H"""
    <.breadcrumbs>
      <:item text="Home" href={~p"/"} />
      <:item text="Modules" href={~p"/modules"} />
      <:item text={@module.name} href={~p"/modules/#{@module.id}/assignments"} />
      <:item
        text="Assignments"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"}
        current={true}
      />
    </.breadcrumbs>

    <.tabs>
      <:item text="Details" href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"} />
      <:item
        text="Environment"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/environment"}
      />
      <:item text="Tests" href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/tests"} />
      <:item
        text="Submissions"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/submissions"}
        current={true}
      />
    </.tabs>

    <div class="flex h-screen">
      <div class="bg-gray-50 dark:bg-gray-800 p-4 w-64 h-full p-4">
        <div class="assignment-test-files">
          <ul>
            <li
              :for={submission_file <- @submission.assignment_submission_files}
              class="py-1 relative flex justify-between items-center hover:bg-gray-200 dark:hover:bg-gray-700 p-[5px] rounded"
              phx-click="select_file"
              phx-value-submission_file_id={submission_file.id}
            >
              <span>
                <svg
                  class="w-4 h-4 mr-2"
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fill-rule="evenodd"
                    d="M5.586 2H15a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2zm10 4v2h-4V6h4zM6 9h8v2H6V9zm0 4h8v2H6v-2z"
                    clip-rule="evenodd"
                  />
                </svg>
              </span>

              <span class="truncate" title={submission_file.file.file_name}>
                <%= submission_file.file.file_name %>
              </span>
            </li>
          </ul>
        </div>
      </div>
      <div class="flex-1 ml-4">
        <div class="assignment-test-form bg-white rounded shadow-md px-4 mb-4  w-full">
          <LiveMonacoEditor.code_editor
            style="min-height: 450px; width: 100%;"
            opts={LiveMonacoEditor.default_opts()}
          />
        </div>
        <div class="flex">
          <button
            type="button"
            class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
            phx-click="run_tests"
            phx-value-assignment_id={@assignment.id}
            disabled={@build && @build.status == "running"}
          >
            <%= if @build, do: "Running", else: "Run All Tests" %>
          </button>
        </div>

        <.accordion logs={@logs} />
      </div>
    </div>
    """
  end

  @impl true
  def mount(
        %{"id" => id, "assignment_id" => assignment_id, "submission_id" => submission_id},
        _session,
        socket
      ) do
    if Modules.assignment_exists?(id, assignment_id) do
      assignment = Assignments.get_assignment!(assignment_id)
      submission = Assignments.get_submission_by_id(submission_id)

      {:ok,
       socket
       |> assign(current_page: :modules)
       |> assign(:module, Modules.get_module!(id))
       |> assign(:assignment, assignment)
       |> assign(:submission, submission)
       |> assign(
         :logs,
         Assignments.build_recent_test_results(assignment_id, submission.user_id)
       )
       |> assign(
         :build,
         Assignments.get_running_build(assignment_id, submission.user_id)
       )}
    else
      {:ok,
       push_navigate(socket, to: ~p"/modules/#{id}/assignments")
       |> put_flash(:error, "You are not authorized to view this page")}
    end
  end

  @impl true
  def handle_event("code-editor-lost-focus", _, socket) do
    {:noreply, socket}
  end

  def handle_event("select_file", %{"submission_file_id" => id}, socket) do
    submission_file =
      AssignmentSubmissions.get_assignment_submission_file!(id)

    url =
      AssignmentSubmissionFileUploader.url({submission_file.file.file_name, submission_file},
        signed: true
      )

    {:ok, %Finch.Response{status: 200, body: body}} =
      Finch.build(:get, url)
      |> Finch.request(Handin.Finch)

    {:noreply,
     socket
     |> assign(:selected_assignment_submission_file, id)
     |> LiveMonacoEditor.set_value(body)}
  end

  def handle_event("run_tests", %{"assignment_id" => assignment_id}, socket) do
    HandinWeb.Endpoint.subscribe("build:assignment_tests:#{assignment_id}")

    DynamicSupervisor.start_child(Handin.BuildSupervisor, %{
      id: Handin.BuildServer,
      start:
        {Handin.BuildServer, :start_link,
         [
           %{
             assignment_id: assignment_id,
             type: "assignment_submission",
             image: socket.assigns.assignment.programming_language.docker_file_url,
             user_id: socket.assigns.submission.user.id
           }
         ]},
      restart: :temporary
    })

    {:noreply,
     assign(
       socket,
       :logs,
       Assignments.build_recent_test_results(assignment_id, socket.assigns.submission.user.id)
     )
     |> assign(
       :build,
       Assignments.get_running_build(assignment_id, socket.assigns.submission.user.id)
     )}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{event: "test_result", payload: build_id},
        socket
      ) do
    {:noreply,
     assign(socket, :logs, Assignments.get_test_results_for_build(build_id))
     |> assign(
       :build,
       Assignments.get_running_build(
         socket.assigns.assignment.id,
         socket.assigns.submission.user.id
       )
     )}
  end
end
