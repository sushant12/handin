defmodule HandinWeb.AssignmentLive.Submit do
  use HandinWeb, :live_view

  alias Handin.{Modules, Assignments}

  @impl true
  def render(assigns) do
    ~H"""
    <.breadcrumbs>
      <:item text="Home" href={~p"/"} />
      <:item text="Modules" href={~p"/modules"} />
      <:item text={@module.name} href={~p"/modules/#{@module.id}/assignments"} />
      <:item
        text={@assignment.name}
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"}
        current={true}
      />
    </.breadcrumbs>

    <.tabs>
      <:item text="Details" href={~p"/modules/#{@module}/assignments/#{@assignment}/details"} />
      <:item
        text="Submit"
        href={~p"/modules/#{@module}/assignments/#{@assignment}/submit"}
        current={true}
      />
    </.tabs>

    <div class="flex justify-between items-center w-1/2">
      <span :if={@assignment.enable_max_attempts} class="whitespace-nowrap">
        Attempts remaining: <%= @assignment.max_attempts - @assignment_submission.retries %>
      </span>
      <span :if={@assignment.enable_total_marks} class="whitespace-nowrap">
        Grade: <%= @assignment_submission.total_points %> / <%= @assignment.total_marks %>
      </span>
    </div>

    <.header class="mb-4">
      Assignment Submission
    </.header>
    <.link
      :if={Assignments.submission_allowed?(@assignment_submission)}
      class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800 mb-4"
      patch={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/upload_submissions"}
    >
      Upload Files
    </.link>
    <div class="w-1/2">
      <.table id="helper-files" rows={@assignment_submission_files}>
        <:col :let={file} label="name"><%= file.file.file_name %></:col>
        <:action :let={file}>
          <.link
            :if={Assignments.submission_allowed?(@assignment_submission)}
            class="focus:outline-none text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-4 py-2 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 dark:focus:ring-red-900"
            phx-click={JS.push("delete-submission-file", value: %{id: file.id})}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </div>

    <.button
      :if={Assignments.submission_allowed?(@assignment_submission)}
      class="text-white inline-flex items-center bg-green-700 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800 my-4"
      phx-click="submit_assignment"
      phx-value-assignment_id={@assignment.id}
    >
      <%= if @build, do: "Submitting...", else: "Submit Assignment" %>
    </.button>

    <div :if={@assignment.enable_test_output} class="w-1/2" id="accordion-open" data-accordion="open">
    </div>

    <div :if={!@assignment.enable_test_output} class="w-1/2">
      <ul class="max-w-md space-y-2 text-gray-500 list-inside dark:text-gray-400"></ul>
    </div>
    <.modal
      :if={@live_action == :upload_submissions}
      id="assignment_submissions-modal"
      show
      on_cancel={JS.patch(~p"/modules/#{@module.id}/assignments/#{@assignment.id}/submit")}
    >
      <.live_component
        module={HandinWeb.AssignmentSubmissionsLive.AssignmentUploadComponent}
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
    user = socket.assigns.current_user

    with {:ok, module} <- Modules.get_module(id),
         {:ok, module_user} <-
           Modules.module_user(module, user),
         {:ok, assignment} <- Assignments.get_assignment(assignment_id, module.id) do
      assignment_submission =
        Assignments.get_submission(assignment_id, user.id) ||
          Assignments.create_submission(assignment_id, user.id)

      if connected?(socket) do
        HandinWeb.Endpoint.subscribe(
          "assignment:#{assignment_id}:module_user:#{user.id}:role:#{module_user.role}"
        )
      end

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
          :build,
          GenServer.whereis(
            {:global,
             "assignment:#{assignment_id}:module_user:#{user.id}:role:#{module_user.role}"}
          )
        )
        |> assign(:assignment_submission, assignment_submission)
        |> assign(
          :assignment_submission_files,
          Map.get(assignment_submission, :assignment_submission_files, [])
        )
        |> assign(
          :submission_errors,
          Assignments.get_submission_errors(assignment_submission)
        )
      }
    else
      {:error, reason} ->
        {:ok,
         push_navigate(socket, to: ~p"/modules/#{id}/assignments")
         |> put_flash(:error, reason)}
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
    if Assignments.submission_allowed?(socket.assigns.assignment_submission) do
      DynamicSupervisor.start_child(Handin.BuildSupervisor, %{
        id: Handin.AssignmentSubmissionServer,
        start:
          {Handin.AssignmentSubmissionServer, :start_link,
           [
             %{
               assignment_id: assignment_id,
               assignment_submission_id: socket.assigns.assignment_submission.id,
               image: socket.assigns.assignment.programming_language.docker_file_url,
               user_id: socket.assigns.current_user.id,
               role: socket.assigns.current_user.role,
               build_identifier: Ecto.UUID.generate()
             }
           ]},
        restart: :temporary
      })

      {:noreply,
       socket
       |> assign(
         :build,
         GenServer.whereis(
           {:global,
            "assignment:#{assignment_id}:module_user:#{socket.assigns.current_user.id}:role:#{socket.assigns.current_user.role}"}
         )
       )}
    else
      {:noreply, socket}
    end
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
        %Phoenix.Socket.Broadcast{event: event, payload: _build_id},
        socket
      ) do
    case event do
      "test_result" ->
        {:noreply,
         socket
         |> assign(
           :build,
           GenServer.whereis(
             {:global,
              "assignment:#{socket.assigns.assignment.id}:module_user:#{socket.assigns.current_user.id}:role:#{socket.assigns.current_user.role}"}
           )
         )}

      "build_completed" ->
        submission =
          Assignments.get_submission(socket.assigns.assignment.id, socket.assigns.current_user.id)

        {:noreply,
         socket
         |> assign(
           :build,
           nil
         )
         |> assign(:assignment_submission, submission)
         |> assign(:submission_errors, Assignments.get_submission_errors(submission))}
    end
  end

  def handle_info(
        {HandinWeb.AssignmentSubmissionsLive.AssignmentUploadComponent, {:saved, assignment}},
        socket
      ) do
    assignment_submission =
      Assignments.get_submission(assignment.id, socket.assigns.current_user.id)

    {:noreply,
     assign(socket, :assignment_submission, assignment_submission)
     |> assign(:assignment_submission_files, assignment_submission.assignment_submission_files)}
  end
end
