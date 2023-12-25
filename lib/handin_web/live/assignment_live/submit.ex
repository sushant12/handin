defmodule HandinWeb.AssignmentLive.Submit do
  use HandinWeb, :live_view
  import HandinWeb.AssignmentLive.AccordionComponent

  alias Handin.{Modules, Assignments, Accounts}

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
      />
      <:item
        text={@assignment.name}
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"}
        current={true}
      />
    </.breadcrumbs>

    <%= if @current_user.role != "student" do %>
      <.tabs>
        <:item
          text="Details"
          href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"}
          current={true}
        />
        <:item
          text="Environment"
          href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/environment"}
        />
        <:item text="Tests" href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/tests"} />
        <:item
          text="Submissions"
          href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/submissions"}
        />
      </.tabs>
    <% end %>
    <%= if @current_user.role == "student" do %>
      <.tabs>
        <:item text="Details" href={~p"/modules/#{@module}/assignments/#{@assignment}/details"} />
        <:item
          text="Submit"
          href={~p"/modules/#{@module}/assignments/#{@assignment}/submit"}
          current={true}
        />
      </.tabs>
    <% end %>

    <div>
      <div class="items-center justify-between mb-4">
        <h2 class="text-xl font-semibold">Assignment Submission</h2>
        <.link
          class="block w-[8rem] text-white bg-blue-700 hover:bg-ble-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 text-center mr-3 md:mr-0 "
          patch={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/upload_submissions"}
        >
          Upload Files
        </.link>
        <ul class="space-y-4 text-left text-gray-500 dark:text-gray-400 p-5">
          <li
            :for={file <- @assignment_submission_files}
            class="flex items-center space-x-3 rtl:space-x-reverse"
          >
            <%= file.file.file_name %>
            <span class="delete-icon">
              <.button phx-click="delete-submission-file" phx-value-id={file.id}>
                <svg
                  class="w-[21px] h-[21px] text-gray-800 dark:text-white"
                  aria-hidden="true"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 18 20"
                >
                  <path
                    stroke="red"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.5"
                    d="M1 5h16M7 8v8m4-8v8M7 1h4a1 1 0 0 1 1 1v3H6V2a1 1 0 0 1 1-1ZM3 5h12v13a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V5Z"
                  />
                </svg>
              </.button>
            </span>
          </li>
        </ul>

        <button
          type="button"
          class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
          phx-click="submit_assignment"
          phx-value-assignment_id={@assignment.id}
        >
          <%= if @build, do: "Submitting...", else: "Submit Assignment" %>
        </button>
      </div>

      <.accordion logs={@logs} />
    </div>
    <.modal
      :if={@live_action == :upload_submissions}
      id="assignment_submissions-modal"
      show
      on_cancel={JS.patch(~p"/modules/#{@module.id}/assignments/#{@assignment.id}/submit")}
    >
      <.live_component
        module={HandinWeb.AssignmentLive.FileUploadComponent}
        title={@page_title}
        id={@assignment.id}
        live_action={@live_action}
        assignment={@assignment}
        patch={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/submit"}
        current_user={@current_user}
        assignment_submission={@assignment_submission}
      />
    </.modal>
    """
  end

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    with true <- Accounts.enrolled_module?(socket.assigns.current_user, id),
         true <- Modules.assignment_exists?(id, assignment_id) do
      assignment = Assignments.get_assignment!(assignment_id)
      module = Modules.get_module!(id)

      assignment_submission =
        Assignments.get_submission(assignment_id, socket.assigns.current_user.id) ||
          Assignments.create_submission(assignment_id, socket.assigns.current_user.id)

      {
        :ok,
        socket
        |> assign(current_page: :modules)
        |> assign(:module, module)
        |> assign(:assignment, assignment)
        |> assign(:page_title, "#{module.name} - #{assignment.name}")
        |> assign(
          :assignment_tests,
          assignment.assignment_tests
        )
        |> assign(
          :logs,
          Assignments.build_recent_test_results(assignment_id, socket.assigns.current_user.id)
        )
        |> assign(
          :build,
          Assignments.get_running_build(assignment_id, socket.assigns.current_user.id)
        )
        |> assign(:assignment_submission, assignment_submission)
        |> assign(
          :assignment_submission_files,
          Map.get(assignment_submission, :assignment_submission_files, [])
        )
      }
    else
      false ->
        {:ok,
         push_navigate(socket, to: ~p"/modules")
         |> put_flash(:error, "You are not authorized to view this page")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :upload_submissions, _) do
    socket
    |> assign(:page_title, "Upload Submissions")
  end

  defp apply_action(socket, _, _) do
    socket
  end

  @impl true

  def handle_event("submit_assignment", %{"assignment_id" => assignment_id}, socket) do
    HandinWeb.Endpoint.subscribe("build:assignment_submission:#{assignment_id}")

    DynamicSupervisor.start_child(Handin.BuildSupervisor, %{
      id: Handin.BuildServer,
      start:
        {Handin.BuildServer, :start_link,
         [
           %{
             assignment_id: assignment_id,
             type: "assignment_submission",
             image: socket.assigns.assignment.programming_language.docker_file_url,
             user_id: socket.assigns.current_user.id
           }
         ]},
      restart: :temporary
    })

    {:noreply,
     assign(
       socket,
       :logs,
       Assignments.build_recent_test_results(assignment_id, socket.assigns.current_user.id)
     )
     |> assign(
       :build,
       Assignments.get_running_build(assignment_id, socket.assigns.current_user.id)
     )}
  end

  def handle_event("delete-submission-file", %{"id" => id}, socket) do
    Enum.find(socket.assigns.assignment_submission.assignment_submission_files, fn sf ->
      sf.id == id
    end)
    |> Assignments.delete_assignment_submission_file()

    submission =
      Assignments.get_submission(socket.assigns.assignment.id, socket.assigns.current_user.id)

    {:noreply,
     assign(socket, :assignment_submission, submission)
     |> assign(:assignment_submission_files, submission.assignment_submission_files)}
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
       Assignments.get_running_build(socket.assigns.assignment.id, socket.assigns.current_user.id)
     )}
  end

  def handle_info({HandinWeb.AssignmentLive.FileUploadComponent, {:saved, assignment}}, socket) do
    assignment_submission =
      Assignments.get_submission(assignment.id, socket.assigns.current_user.id)

    {:noreply,
     assign(socket, :assignment_submission, assignment_submission)
     |> assign(:assignment_submission_files, assignment_submission.assignment_submission_files)}
  end
end
