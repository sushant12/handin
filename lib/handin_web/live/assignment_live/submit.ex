defmodule HandinWeb.AssignmentLive.Submit do
  use HandinWeb, :live_view

  alias Handin.Repo
  alias Handin.Modules
  alias Handin.{Assignments, AssignmentTests}
  alias Handin.Assignments.AssignmentTest
  alias Handin.AssignmentSubmission.AssignmentSubmission

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
        assignment_submission={
          @assignment_submission || %AssignmentSubmission{assignment_submission_files: []}
        }
      />
    </.modal>
    """
  end

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    assignment = Assignments.get_assignment!(assignment_id)
    assignment_test = Enum.at(assignment.assignment_tests, 0)

    assignment_submission =
      Assignments.get_submission(assignment_id, socket.assigns.current_user.id)

    {:ok,
     socket
     |> assign(current_page: :modules)
     |> assign(:module, Modules.get_module!(id))
     |> assign(:assignment, assignment)
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
       (assignment_submission && assignment_submission.assignment_submission_files) || []
     )
     |> assign_form(
       AssignmentTests.change_assignment_test(
         assignment_test || %AssignmentTest{assignment_id: assignment.id}
       )
     )}
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
  def handle_event("add-new-test", _, socket) do
    {:ok, assignment_test} =
      %{
        name: "New Test",
        assignment_id: socket.assigns.assignment.id
      }
      |> AssignmentTests.create_assignment_test()

    {:noreply,
     socket
     |> assign(:assignment_test, assignment_test)
     |> assign_form(AssignmentTests.change_assignment_test(assignment_test))
     |> assign(
       :assignment_tests,
       socket.assigns.assignment_tests ++ [assignment_test]
     )}
  end

  def handle_event("select-test", %{"id" => id}, socket) do
    assignment_test = AssignmentTests.get_assignment_test!(id)

    {:noreply,
     assign(socket, :assignment_test, assignment_test)
     |> assign_form(AssignmentTests.change_assignment_test(assignment_test))}
  end

  def handle_event("delete-test", %{"id" => id}, socket) do
    assignment_test = AssignmentTests.get_assignment_test!(id)
    {:ok, _} = AssignmentTests.delete_assignment_test(assignment_test)

    assignment = Assignments.get_assignment!(socket.assigns.assignment.id)
    assignment_test = Enum.at(assignment.assignment_tests, 0)

    if assignment_test do
      {:noreply,
       assign(
         socket,
         :assignment_tests,
         assignment.assignment_tests
       )
       |> assign(:assignment_test, assignment_test)
       |> assign_form(AssignmentTests.change_assignment_test(assignment_test))}
    else
      {:noreply,
       assign(socket, :assignment_tests, assignment.assignment_tests)
       |> assign(:assignment_test, nil)}
    end
  end

  def handle_event("validate", %{"assignment_test" => assignment_test_params}, socket) do
    changeset =
      socket.assigns.assignment_test
      |> AssignmentTests.change_assignment_test(assignment_test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("update_name", %{"value" => value}, socket) do
    {:ok, assignment_test} =
      Handin.Assignments.AssignmentTest.new_changeset(socket.assigns.assignment_test, %{
        name: value
      })
      |> Repo.update()

    assignment = socket.assigns.assignment |> Repo.preload(:assignment_tests, force: true)

    {:noreply,
     assign(socket, :assignment_test, assignment_test)
     |> assign(
       :assignment_tests,
       assignment.assignment_tests
     )}
  end

  def handle_event("update_expected_output_file", %{"value" => value}, socket) do
    socket.assigns.assignment_test
    |> Repo.preload(assignment: [:support_files])
    |> Handin.Assignments.AssignmentTest.output_file_changeset(%{
      expected_output_file: value
    })
    |> Repo.update()
    |> case do
      {:ok, assignment_test} ->
        {:noreply, assign(socket, :assignment_test, assignment_test)}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("update_" <> key, %{"value" => value}, socket) do
    {:ok, assignment_test} =
      Handin.Assignments.AssignmentTest.new_changeset(socket.assigns.assignment_test, %{
        "#{key}": value
      })
      |> Repo.update()

    {:noreply, assign(socket, :assignment_test, assignment_test)}
  end

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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
