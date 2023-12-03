defmodule HandinWeb.AssignmentLive.Tests do
  use HandinWeb, :live_view

  alias Handin.Modules
  alias Handin.{Assignments, AssignmentTests}
  alias Handin.Assignments.AssignmentTest

  @impl true
  def render(assigns) do
    ~H"""
    <.breadcrumbs>
      <:item text="Home" href={~p"/"} />
      <:item text="Modules" href={~p"/modules"} />
      <:item text={@module.name} href={~p"/modules/#{@module.id}/assignments"} />
      <:item
        text="Assignments"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}"}
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
    </.tabs>

    <div class="assignment-test-container flex">
      <div class="assignment-test-sidebar bg-gray-200 p-4">
        <div class="assignment-test-files">
          <ul>
            <li
              :if={@assignment.support_files == [] && @assignment.solution_files == []}
              class="py-1 flex items-center"
            >
              No files added
            </li>
            <li :for={support_file <- @assignment.support_files} class="py-1 flex items-center">
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
              <span><%= support_file.file.file_name %></span>
            </li>
            <li :for={solution_file <- @assignment.solution_files} class="py-1 flex items-center">
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
              <span><%= solution_file.file.file_name %></span>
            </li>
          </ul>
        </div>
        <div class="border-t border-gray-300 mt-4 pt-2">
          <.link
            class="block w-full text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 text-center mr-3 md:mr-0 "
            phx-click="add-new-test"
          >
            Add Tests
          </.link>
        </div>
        <div class="border-t border-gray-300 mt-2 pt-2">
          <div class="assignment-test-tests">
            <ul>
              <li
                :for={test <- @assignment_tests}
                class="py-1 relative flex justify-between items-center"
              >
                <.link phx-click="select-test" phx-value-id={test.id}><%= test.name %></.link>
                <span class="delete-icon">
                  <.button phx-click="delete-test" phx-value-id={test.id}>
                    <svg
                      width="18px"
                      height="18px"
                      viewBox="0 0 24 24"
                      id="Layer_1"
                      data-name="Layer 1"
                      xmlns="http://www.w3.org/2000/svg"
                      fill="#ff0000"
                      stroke="#ff0000"
                    >
                      <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                      <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round">
                      </g>
                      <g id="SVGRepo_iconCarrier">
                        <defs>
                          <style>
                            .cls-1{fill:none;stroke:#ff0000;stroke-miterlimit:10;stroke-width:1.91px;}
                          </style>
                        </defs>
                        <path
                          class="cls-1"
                          d="M16.88,22.5H7.12a1.9,1.9,0,0,1-1.9-1.8L4.36,5.32H19.64L18.78,20.7A1.9,1.9,0,0,1,16.88,22.5Z"
                        >
                        </path>
                        <line class="cls-1" x1="2.45" y1="5.32" x2="21.55" y2="5.32"></line>
                        <path
                          class="cls-1"
                          d="M10.09,1.5h3.82a1.91,1.91,0,0,1,1.91,1.91V5.32a0,0,0,0,1,0,0H8.18a0,0,0,0,1,0,0V3.41A1.91,1.91,0,0,1,10.09,1.5Z"
                        >
                        </path>
                        <line class="cls-1" x1="12" y1="8.18" x2="12" y2="19.64"></line>
                        <line class="cls-1" x1="15.82" y1="8.18" x2="15.82" y2="19.64"></line>
                        <line class="cls-1" x1="8.18" y1="8.18" x2="8.18" y2="19.64"></line>
                      </g>
                    </svg>
                  </.button>
                </span>
              </li>
            </ul>
          </div>
        </div>
      </div>
      <div class="assignment-test-container flex-1 p-2">
        <div class="assignment-test-form bg-white rounded shadow-md px-4 mb-4 h-[57%] w-full">
          <.simple_form
            :if={@assignment_test}
            for={@form}
            id="test-creation-form"
            class="mb-4"
            phx-change="validate_and_save"
          >
            <div class="grid grid-cols-12 gap-4">
              <label class="col-span-3 p-4">Name</label>
              <span class="col-span-9">
                <.input field={@form[:name]} type="text" />
              </span>
              <label class="col-span-3 p-4">Points on pass</label>
              <span class="col-span-9">
                <.input field={@form[:points_on_pass]} type="number" />
              </span>
              <label class="col-span-3 p-4">Points on fail</label>
              <span class="col-span-9">
                <.input field={@form[:points_on_fail]} type="number" />
              </span>
              <label class="col-span-3 p-4">Run command</label>
              <span class="col-span-9">
                <.input field={@form[:command]} type="text" />
              </span>
              <label class="col-span-3 p-4">Expected output</label>
              <span class="col-span-9">
                <.input
                  field={@form[:expected_output_type]}
                  type="select"
                  options={["text", "file"]}
                  prompt="Select expected output type"
                />
              </span>
              <span :if={@form[:expected_output_type].value == "text"} class="col-span-9 col-start-4">
                <.input field={@form[:expected_output_text]} type="text" />
              </span>
              <span :if={@form[:expected_output_type].value == "file"} class="col-span-9 col-start-4">
                <.input field={@form[:expected_output_file]} type="text" placeholder="Filename" />
              </span>
            </div>
            <pre class="text-gray-700">pseudocode: if <%=  @assignment_test.command %> == <%= if @assignment_test.expected_output_type == "file", do: "cat(#{@assignment_test.expected_output_file})", else: @assignment_test.expected_output_text %> then true else false</pre>
          </.simple_form>
        </div>
        <div class="assignment-test-output bg-gray-800 rounded shadow-md p-4 h-64 w-full">
          <p>Welcome to Terminal</p>
          <p>></p>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    assignment = Assignments.get_assignment!(assignment_id)
    assignment_test = Enum.at(assignment.assignment_tests, 0)

    {:ok,
     socket
     |> assign(current_page: :modules)
     |> assign(:module, Modules.get_module!(id))
     |> assign(:assignment, assignment)
     |> assign(:assignment_test, assignment_test)
     |> assign(:assignment_tests, assignment.assignment_tests)
     |> assign(:logs, [])
     |> assign_form(
       AssignmentTests.change_assignment_test(
         assignment_test || %AssignmentTest{assignment_id: assignment.id}
       )
     )}
  end

  @impl true
  def handle_event("add-new-test", _, socket) do
    {:ok, assignment_test} =
      %{
        name: "Default Test",
        assignment_id: socket.assigns.assignment.id,
        points_on_pass: 0,
        points_on_fail: 0,
        command: "START",
        expected_output_type: "type"
      }
      |> AssignmentTests.create_assignment_test()

    {:noreply,
     socket
     |> assign(:assignment_test, assignment_test)
     |> assign_form(AssignmentTests.change_assignment_test(assignment_test))
     |> assign(
       :assignment_tests,
       AssignmentTests.list_assignment_tests_for_assignment(socket.assigns.assignment.id)
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

    {:noreply,
     assign(
       socket,
       :assignment_tests,
       Enum.reject(socket.assigns.assignment_tests, &(&1.id == assignment_test.id))
     )
     |> assign(:assignment_test, nil)
     |> assign_form(AssignmentTests.change_assignment_test(%AssignmentTest{}))}
  end

  def handle_event("validate_and_save", %{"assignment_test" => assignment_test_params}, socket) do
    changeset =
      socket.assigns.assignment_test
      |> AssignmentTests.change_assignment_test(assignment_test_params)
      |> Map.put(:action, :validate)

    changeset.changes
    |> Enum.each(fn {k, v} ->
      AssignmentTests.update_assignment_test(socket.assigns.assignment_test, %{k => v})
    end)

    assignment_test = AssignmentTests.get_assignment_test!(socket.assigns.assignment_test.id)

    changeset =
      assignment_test
      |> AssignmentTests.change_assignment_test(assignment_test_params)
      |> Map.put(:action, :validate)

    {:noreply,
     assign_form(socket, changeset)
     |> assign(
       :assignment_test,
       assignment_test
     )
     |> assign(
       :assignment_tests,
       AssignmentTests.list_assignment_tests_for_assignment(socket.assigns.assignment.id)
     )}
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

  # Note: get logs needs to be fixed. logs are not being casted
  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{event: "new_log", payload: build_id},
        socket
      ) do
    {:noreply, assign(socket, :logs, Assignments.get_logs(build_id))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
