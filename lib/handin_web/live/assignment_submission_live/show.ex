defmodule HandinWeb.AssignmentSubmissionsLive.Show do
  use HandinWeb, :live_view

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
        text={@assignment.name}
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
      <:item text="Settings" href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/settings"} />
    </.tabs>
    <div class="flex mb-5">
      <div class="mr-8 w-64 bg-gray-50 p-4">
        Keyboards Shortcuts:
        <ul class="mt-2">
          <li>Right Arrow &rarr; : Next</li>
          <li>Left Arrow &larr; : Previous</li>
        </ul>
      </div>
      <div class="w-1/2">
        <form
          phx-change="change_student_email"
          id="student_email_selector"
          phx-hook="ChangeSubmissionEmail"
        >
          <.input
            name="student_id"
            type="select"
            value={@submission.user.id}
            options={Enum.map(@students, &{&1.email, &1.id})}
          />
        </form>
        <div class="flex items-center mt-4">
          <%= if @assignment.enable_total_marks do %>
            <span class="mr-2"> Grade: </span>
            <input
              name="student_grade"
              type="number"
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-24 p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
              value={@submission.total_points}
              phx-blur="change_submission_grade"
            /> <span class="mx-2 whitespace-nowrap mr-8">/ {@assignment.total_marks}</span>
          <% end %>
          <%= if @assignment.enable_max_attempts do %>
            <span class="mr-2"> Attempts: </span>
            <input
              name="student_attempts"
              type="number"
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-24 p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
              value={@submission.retries}
              phx-blur="change_submission_attempts"
              step="1"
            /> <span class="mx-2 whitespace-nowrap mr-8">/ {@assignment.max_attempts}</span>
          <% end %>
        </div>
      </div>
    </div>
    <div class="flex">
      <div class="bg-gray-50 dark:bg-gray-800 p-4 w-64 h-auto overflow-y-auto p-4">
        <div class="assignment-test-files">
          <ul>
            <li
              :for={submission_file <- @submission.assignment_submission_files}
              class={[
                "py-1 flex items-center cursor-pointer hover:bg-gray-200 dark:hover:bg-gray-700",
                submission_file.id == @selected_assignment_submission_file && "bg-gray-300"
              ]}
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
                {submission_file.file.file_name}
              </span>
            </li>
          </ul>
        </div>
      </div>
      <div class="ml-8 w-1/2">
        <div class="mb-4">
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
          >
            {if @build, do: "Running...", else: "Run All Tests"}
          </button>
        </div>

        <div id="accordion-open" data-accordion="open">
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
                  {log.name}
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
                  {log.expected_output}
                </p>
                <p class="font-semibold">Got:</p>
                <p class="text-gray-500 dark:text-gray-400">
                  {log.output}
                </p>
              </div>
            </div>
          <% end %>
        </div>
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
      submissions = Assignments.get_submissions_for_assignment(assignment_id)
      submission = submissions |> Enum.find(&(&1.id == submission_id))
      students = submissions |> Enum.map(& &1.user)
      user = socket.assigns.current_user
      module = Modules.get_module!(id)

      {:ok, module_user} =
        Modules.module_user(module, user)

      if connected?(socket) do
        HandinWeb.Endpoint.subscribe(
          "assignment:#{assignment_id}:module_user:#{user.id}:role:#{module_user.role}"
        )
      end

      {:ok,
       socket
       |> assign(current_page: :modules)
       |> assign(:module, module)
       |> assign(:module_user, module_user)
       |> assign(:assignment, assignment)
       |> assign(:submission, submission)
       |> assign(:submissions, submissions)
       |> assign(:students, students)
       |> assign(:selected_assignment_submission_file, nil)
       |> assign(
         :logs,
         Assignments.build_recent_test_results(assignment_id, submission.user_id)
       )
       |> assign(
         :build,
         GenServer.whereis(
           {:global,
            "assignment:#{assignment_id}:module_user:#{user.id}:role:#{module_user.role}"}
         )
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
    user = socket.assigns.current_user
    module_user = socket.assigns.module_user
    image = socket.assigns.assignment.programming_language.docker_file_url

    DynamicSupervisor.start_child(Handin.BuildSupervisor, %{
      id: Handin.BuildServer,
      start:
        {Handin.BuildServer, :start_link,
         [
           %{
             assignment_id: assignment_id,
             role: module_user.role,
             image: image,
             user_id: user.id,
             build_identifier: Ecto.UUID.generate()
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
       GenServer.whereis(
         {:global, "assignment:#{assignment_id}:module_user:#{user.id}:role:#{module_user.role}"}
       )
     )}
  end

  def handle_event("change_student_email", %{"student_id" => student_id}, socket) do
    submission = socket.assigns.submissions |> Enum.find(&(&1.user_id == student_id))

    {:noreply,
     push_navigate(socket,
       to:
         ~p"/modules/#{socket.assigns.module.id}/assignments/#{socket.assigns.assignment.id}/submission/#{submission.id}"
     )}
  end

  def handle_event("next_submission", _, socket) do
    current_submission_index =
      socket.assigns.submissions
      |> Enum.find_index(&(&1.user_id == socket.assigns.submission.user_id))

    next_submission = socket.assigns.submissions |> Enum.at(current_submission_index + 1)

    next_submission =
      if next_submission do
        next_submission
      else
        Enum.at(socket.assigns.submissions, 0)
      end

    {:noreply,
     push_navigate(socket,
       to:
         ~p"/modules/#{socket.assigns.module.id}/assignments/#{socket.assigns.assignment.id}/submission/#{next_submission.id}"
     )}
  end

  def handle_event("previous_submission", _, socket) do
    current_submission_index =
      socket.assigns.submissions
      |> Enum.find_index(&(&1.user_id == socket.assigns.submission.user_id))

    prev_submission = socket.assigns.submissions |> Enum.at(current_submission_index - 1)

    prev_submission =
      if prev_submission do
        prev_submission
      else
        Enum.at(socket.assigns.submissions, 0)
      end

    {:noreply,
     push_navigate(socket,
       to:
         ~p"/modules/#{socket.assigns.module.id}/assignments/#{socket.assigns.assignment.id}/submission/#{prev_submission.id}"
     )}
  end

  def handle_event("increase-grade", _, socket) do
    total_points = socket.assigns.submission.total_points + 1

    case Assignments.create_or_update_submission(%{
           user_id: socket.assigns.submission.user_id,
           assignment_id: socket.assigns.assignment.id,
           total_points: total_points
         }) do
      {:ok, submission} ->
        {:noreply, socket |> assign(:submission, submission)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {error, _} = changeset.errors[:total_points]
        {:noreply, put_flash(socket, :error, error)}
    end
  end

  def handle_event("decrease-grade", _, socket) do
    total_points = socket.assigns.submission.total_points - 1

    case Assignments.create_or_update_submission(%{
           user_id: socket.assigns.submission.user_id,
           assignment_id: socket.assigns.assignment.id,
           total_points: total_points
         }) do
      {:ok, submission} ->
        {:noreply, socket |> assign(:submission, submission)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {error, _} = changeset.errors[:total_points]
        {:noreply, put_flash(socket, :error, error)}
    end
  end

  def handle_event("change_submission_grade", %{"value" => total_points}, socket) do
    {:ok, submission} =
      Assignments.create_or_update_submission(%{
        user_id: socket.assigns.submission.user_id,
        assignment_id: socket.assigns.assignment.id,
        total_points: total_points
      })

    {:noreply, socket |> assign(:submission, submission)}
  end

  def handle_event("change_submission_attempts", %{"value" => retries}, socket) do
    {:ok, submission} =
      Assignments.create_or_update_submission(%{
        user_id: socket.assigns.submission.user_id,
        assignment_id: socket.assigns.assignment.id,
        retries: retries
      })

    {:noreply, socket |> assign(:submission, submission)}
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
           GenServer.whereis({:global, "build:assignment_tests:#{socket.assigns.assignment.id}"})
         )}

      "build_completed" ->
        {:noreply,
         assign(socket, :logs, Assignments.get_test_results_for_build(build_id))
         |> assign(
           :build,
           nil
         )}
    end
  end
end
