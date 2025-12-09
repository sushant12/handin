defmodule HandinWeb.AssignmentLive.Tests do
  use HandinWeb, :live_view

  alias Handin.Modules
  alias Handin.{Assignments, AssignmentTests}
  alias Handin.Assignments.AssignmentTest
  alias Handin.AssignmentFileUploader

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
      <:item
        text="Tests"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/tests"}
        current={true}
      />
      <:item
        text="Submissions"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/submissions"}
      />
      <:item text="Settings" href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/settings"} />
    </.tabs>

    <div class="flex">
      <div class="bg-gray-50 dark:bg-gray-800 p-4 w-64 h-auto overflow-y-auto p-4">
        <div class="assignment-test-files">
          <ul>
            <li
              :for={assignment_file <- @assignment.assignment_files}
              :if={assignment_file.file_type == :test_resource}
              class="py-1 flex items-center"
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
              <a
                href={
                  AssignmentFileUploader.url({assignment_file.file.file_name, assignment_file},
                    signed: true
                  )
                }
                download={assignment_file.file.file_name}
                class="truncate hover:text-blue-600 dark:hover:text-blue-400 cursor-pointer"
                title={assignment_file.file.file_name}
              >
                {assignment_file.file.file_name}
              </a>
            </li>
            <li
              :for={assignment_file <- @assignment.assignment_files}
              :if={assignment_file.file_type == :solution}
              class="py-1 flex items-center text text-gray-300"
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

              <span class="truncate" title={assignment_file.file.file_name}>
                {assignment_file.file.file_name}
              </span>
            </li>
          </ul>
        </div>
        <div class="border-t border-gray-300 mt-4 pt-2">
          <.link
            class="block w-full text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 text-center mr-3 md:mr-0 "
            phx-click="add_test"
          >
            Add Tests
          </.link>
        </div>
        <div class="border-t border-gray-300 mt-2 pt-2">
          <div class="assignment-test-tests">
            <ul>
              <li
                :for={test <- @assignment_tests}
                class={[
                  "py-1 relative flex justify-between items-center hover:bg-gray-200 dark:hover:bg-gray-700 p-2 rounded",
                  test.id == @selected_assignment_test.id && "bg-gray-300"
                ]}
              >
                <.link
                  phx-click="select_test"
                  phx-value-id={test.id}
                  class="truncate"
                  title={test.name}
                >
                  {test.name}
                </.link>

                <span class="delete-icon">
                  <.button phx-click="delete_test" phx-value-id={test.id}>
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
          </div>
        </div>
      </div>
      <div class="ml-8 w-1/2">
        <div class="rounded shadow-md px-4 mb-5 pb-5">
          <.simple_form
            :if={@selected_assignment_test}
            for={@form}
            phx-change="validate"
            phx-submit="save"
          >
            <.input field={@form[:name]} type="text" label="Name" />
            <.input field={@form[:enable_custom_test]} type="checkbox" label="Enable Custom Test" />
            <%= if @assignment.enable_total_marks do %>
              <.input field={@form[:points_on_pass]} type="number" label="Points on Pass" step="0.5" />
              <.input field={@form[:points_on_fail]} type="number" label="Points on Fail" step="0.5" />
            <% end %>
            <%= if Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_custom_test].value) do %>
              <.label for="Custom Test">Custom Test</.label>
              <LiveMonacoEditor.code_editor
                style="min-height: 450px;"
                class="mt-3 w-full"
                value={@selected_assignment_test.custom_test}
                opts={
                  Map.merge(
                    LiveMonacoEditor.default_opts(),
                    %{"language" => "shell"}
                  )
                }
              />
            <% else %>
              <.input field={@form[:command]} type="text" label="Command" />
              <.input field={@form[:ttl]} type="number" label="Timeout(second)" />
              <.input
                field={@form[:expected_output_type]}
                type="select"
                label="Match Type"
                options={[:file, :string]}
              />
              <.input
                :if={@form[:expected_output_type].value in ["file", :file]}
                field={@form[:expected_output_file]}
                type="select"
                label="File"
                options={
                  Enum.filter(@assignment.assignment_files, &(&1.file_type == :test_resource))
                  |> Enum.map(&{&1.file.file_name, &1.file.file_name})
                }
              />

              <.input
                :if={@form[:expected_output_type].value in [:string, "string"]}
                field={@form[:expected_output_text]}
                type="text"
                label="Expected Text"
              />
            <% end %>
            <.input field={@form[:enable_test_sleep]} type="checkbox" label="Enable Test Sleep" />
            <.input
              :if={Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_test_sleep].value)}
              field={@form[:test_sleep_duration]}
              type="number"
              label="Test Sleep Duration (minutes)"
              step="1"
            />
            <.input field={@form[:always_pass_test]} type="checkbox" label="Always Pass Test" />
            <.button
              class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
              phx-disable-with="Saving..."
            >
              Save
            </.button>
          </.simple_form>
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
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    user = socket.assigns.current_user

    with {:ok, module} <- Modules.get_module(id),
         {:ok, module_user} <-
           Modules.module_user(module, user),
         {:ok, assignment} <- Assignments.get_assignment(assignment_id, module.id) do
      if connected?(socket) do
        HandinWeb.Endpoint.subscribe(
          "assignment:#{assignment_id}:module_user:#{user.id}:role:#{module_user.role}"
        )
      end

      assignment_tests = Assignments.list_tests(assignment_id)
      selected_assignment_test = List.first(assignment_tests)

      {:ok,
       socket
       |> assign(current_page: :modules)
       |> assign(:module, module)
       |> assign(:module_user, module_user)
       |> assign(:page_title, "#{module.name} - #{assignment.name}")
       |> assign(:assignment, assignment)
       |> assign(:selected_assignment_test, selected_assignment_test)
       |> assign(:assignment_tests, assignment_tests)
       |> assign(
         :logs,
         Assignments.build_recent_test_results(assignment_id, user.id)
       )
       |> assign(
         :build,
         GenServer.whereis(
           {:global,
            "assignment:#{assignment_id}:module_user:#{user.id}:role:#{module_user.role}"}
         )
       )
       |> assign(:custom_test, selected_assignment_test && selected_assignment_test.custom_test)
       |> assign_form(
         AssignmentTests.change_assignment_test(
           selected_assignment_test || %AssignmentTest{assignment_id: assignment.id}
         )
       )
       |> LiveMonacoEditor.set_value(
         (selected_assignment_test && selected_assignment_test.custom_test) || ""
       )}
    end
  end

  @impl true
  def handle_event("add_test", _, socket) do
    case AssignmentTests.create_assignment_test(%{
           name: "New Test",
           assignment_id: socket.assigns.assignment.id
         }) do
      {:ok, assignment_test} ->
        {:noreply,
         socket
         |> assign(:selected_assignment_test, assignment_test)
         |> assign_form(AssignmentTests.change_assignment_test(assignment_test))
         |> assign(
           :assignment_tests,
           socket.assigns.assignment_tests ++ [assignment_test]
         )}

      {:error, %Ecto.Changeset{}} ->
        {:noreply, put_flash(socket, :error, "Failed to add test")}
    end
  end

  def handle_event("select_test", %{"id" => id}, socket) do
    case AssignmentTests.get_assignment_test(id) do
      {:ok, assignment_test} ->
        {:noreply,
         assign(socket, :selected_assignment_test, assignment_test)
         |> assign(:custom_test, assignment_test.custom_test)
         |> assign_form(AssignmentTests.change_assignment_test(assignment_test))
         |> then(fn socket ->
           if assignment_test.enable_custom_test do
             LiveMonacoEditor.set_value(socket, assignment_test.custom_test)
           else
             socket
           end
         end)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to select test")}
    end
  end

  def handle_event("delete_test", %{"id" => id}, socket) do
    assignment_id = socket.assigns.assignment.id

    with {:ok, assignment_test} <- Assignments.get_test(assignment_id, id),
         {:ok, _} <- AssignmentTests.delete_assignment_test(assignment_test) do
      assignment_tests = Assignments.list_tests(assignment_id)
      assignment_test = List.first(assignment_tests)

      socket =
        assign(socket, :assignment_tests, assignment_tests)
        |> put_flash(:info, "Test deleted successfully")
        |> assign(:assignment_test, assignment_test)

      socket =
        if assignment_test do
          assign_form(socket, AssignmentTests.change_assignment_test(assignment_test))
        else
          socket
        end

      {:noreply, socket}
    else
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete test")}
    end
  end

  def handle_event("validate", %{"assignment_test" => assignment_test_params}, socket) do
    changeset =
      socket.assigns.selected_assignment_test
      |> AssignmentTests.change_assignment_test(assignment_test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"assignment_test" => assignment_test_params}, socket) do
    save_assignment_test(
      socket,
      :edit,
      assignment_test_params |> Map.put("custom_test", socket.assigns.custom_test)
    )
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
       Assignments.build_recent_test_results(assignment_id, socket.assigns.current_user.id)
     )
     |> assign(
       :build,
       GenServer.whereis(
         {:global, "assignment:#{assignment_id}:module_user:#{user.id}:role:#{module_user.role}"}
       )
     )}
  end

  def handle_event("code-editor-lost-focus", %{"value" => custom_test}, socket) do
    {:noreply,
     socket
     |> assign(:custom_test, custom_test)}
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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp save_assignment_test(socket, :edit, params) do
    selected_assignment_test = socket.assigns.selected_assignment_test

    case Assignments.update_assignment_test(
           selected_assignment_test,
           params
         ) do
      {:ok, assignment_test} ->
        assignment_id = socket.assigns.assignment.id
        assignment_tests = Assignments.list_tests(assignment_id)

        {:noreply,
         socket
         |> assign_form(Assignments.change_assignment_test(assignment_test))
         |> assign(:selected_assignment_test, assignment_test)
         |> assign(:assignment_tests, assignment_tests)
         |> put_flash(:info, "Test saved successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
