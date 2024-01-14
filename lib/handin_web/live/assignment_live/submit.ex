defmodule HandinWeb.AssignmentLive.Submit do
  use HandinWeb, :live_view

  alias Handin.{Modules, Assignments, Accounts}

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

    <.header class="mb-4">
      Assignment Submission
    </.header>
    <.link
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
      :if={Assignments.is_submission_allowed?(@assignment_submission)}
      class="text-white inline-flex items-center bg-green-700 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800 my-4"
      phx-click="submit_assignment"
      phx-value-assignment_id={@assignment.id}
    >
      <%= if @build, do: "Submitting...", else: "Submit Assignment" %>
    </.button>

    <div :if={@assignment.enable_test_output} class="w-1/2" id="accordion-open" data-accordion="open">
      <%= for {index, log} <- @logs do %>
        <h2 id={"accordion-open-heading-#{index}"}>
          <button
            type="button"
            class={[
              "flex items-center justify-between w-full p-5 font-medium rtl:text-right border border-b-0 border-gray-200 focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-800 dark:border-gray-700 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 gap-3",
              log.state == :pass && "text-green-500",
              log.state == :fail && "text-red-600"
            ]}
            data-accordion-target={"#accordion-open-body-#{index}"}
            aria-expanded="false"
            aria-controls={"accordion-open-body-#{index}"}
          >
            <span class="flex items-center">
              <svg
                :if={log.state == :pass}
                class="w-6 h-6 text-green-500 dark:text-white"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 8.207-4 4a1 1 0 0 1-1.414 0l-2-2a1 1 0 0 1 1.414-1.414L9 10.586l3.293-3.293a1 1 0 0 1 1.414 1.414Z" />
              </svg>
              <svg
                :if={log.state == :fail}
                class="w-6 h-6 text-red-600 dark:text-white"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 20 20"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="m13 7-6 6m0-6 6 6m6-3a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
                />
              </svg>
              <%= log.name %>
            </span>
            <svg
              data-accordion-icon
              class="w-3 h-3 rotate-180 shrink-0"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 10 6"
            >
              <path
                stroke="currentColor"
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 5 5 1 1 5"
              />
            </svg>
          </button>
        </h2>
        <div
          id={"accordion-open-body-#{index}"}
          class="hidden"
          aria-labelledby={"accordion-open-heading-#{index}"}
        >
          <div class="p-5 border border-b-0 border-gray-200 dark:border-gray-700 dark:bg-gray-900">
            <p class="font-semibold">Expected Output:</p>
            <p class="mb-2 text-gray-500 dark:text-gray-400">
              <%= log.expected_output %>
            </p>
            <p class="font-semibold">Got:</p>
            <p class="text-gray-500 dark:text-gray-400">
              <%= log.output %>
            </p>
          </div>
        </div>
      <% end %>
    </div>

    <div :if={!@assignment.enable_test_output} class="w-1/2">
      <ul class="max-w-md space-y-2 text-gray-500 list-inside dark:text-gray-400">
        <%= for {_index, log} <- @logs do %>
          <li class="flex items-center">
            <svg
              :if={log.state == :pass}
              class="w-5 h-5 me-2 text-green-500 dark:text-green-400 flex-shrink-0"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 8.207-4 4a1 1 0 0 1-1.414 0l-2-2a1 1 0 0 1 1.414-1.414L9 10.586l3.293-3.293a1 1 0 0 1 1.414 1.414Z" />
            </svg>
            <svg
              :if={log.state == :fail}
              class="w-5 h-5 me-2 text-red-500 dark:text-red-400 flex-shrink-0"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
            <%= log.name %>
          </li>
        <% end %>
      </ul>
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
          GenServer.whereis({:global, "build:assignment_submission:#{assignment.id}"})
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
    if Assignments.is_submission_allowed?(socket.assigns.assignment_submission) do
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
         GenServer.whereis({:global, "build:assignment_submission:#{assignment_id}"})
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
        %Phoenix.Socket.Broadcast{event: event, payload: build_id},
        socket
      ) do
    case event do
      "test_result" ->
        {:noreply,
         assign(socket, :logs, Assignments.get_test_results_for_build(build_id))
         |> assign(
           :build,
           GenServer.whereis(
             {:global, "build:assignment_submission:#{socket.assigns.assignment.id}"}
           )
         )}

      "build_completed" ->
        submission =
          Assignments.get_submission(socket.assigns.assignment.id, socket.assigns.current_user.id)

        Assignments.submit_assignment(
          submission.id,
          socket.assigns.assignment.enable_max_attempts
        )

        Assignments.evaluate_marks(submission.id, build_id)

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

  def handle_info({HandinWeb.AssignmentLive.FileUploadComponent, {:saved, assignment}}, socket) do
    assignment_submission =
      Assignments.get_submission(assignment.id, socket.assigns.current_user.id)

    {:noreply,
     assign(socket, :assignment_submission, assignment_submission)
     |> assign(:assignment_submission_files, assignment_submission.assignment_submission_files)}
  end
end
