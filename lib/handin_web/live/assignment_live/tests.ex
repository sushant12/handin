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
                  <svg
                    class="w-4 h-4 fill-current text-red-500 cursor-pointer"
                    xmlns="http://www.w3.org/2000/svg"
                    viewBox="0 0 448 512"
                  >
                    <path d="M240 224V48a16 16 0 0 0-16-16h-32a16 16 0 0 0-16 16v176a16 16 0 0 0 16 16h32a16 16 0 0 0 16-16zM432 80h-80v16a16 16 0 0 1-16 16H112a16 16 0 0 1-16-16v-16H16a16 16 0 0 0-16 16v32a16 16 0 0 0 16 16h16v336a48 48 0 0 0 48 48h320a48 48 0 0 0 48-48V128h16a16 16 0 0 0 16-16V96a16 16 0 0 0-16-16zM316.29 256l37.89-37.89a14.6 14.6 0 0 0-20.6-20.6L295.7 235.4l-37.89-37.89a14.6 14.6 0 0 0-20.6 20.6l37.89 37.89-37.89 37.89a14.6 14.6 0 0 0 20.6 20.6l37.89-37.89 37.89 37.89a14.6 14.6 0 0 0 20.6-20.6zM152 400a16 16 0 1 1 16-16 16 16 0 0 1-16 16zm96 0a16 16 0 1 1 16-16 16 16 0 0 1-16 16zm96 0a16 16 0 1 1 16-16 16 16 0 0 1-16 16z" />
                  </svg>
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
            phx-change="validate"
          >
            <div class="grid grid-cols-12 gap-4">
              <label class="col-span-3 p-4">Name</label>
              <span class="col-span-9">
                <.input
                  field={@form[:name]}
                  type="text"
                  phx-blur="save-field"
                  phx-value-target="name"
                />
              </span>
              <label class="col-span-3 p-4">Points on pass</label>
              <span class="col-span-9">
                <.input
                  field={@form[:points_on_pass]}
                  type="number"
                  phx-blur="save-field"
                  phx-value-target="points_on_pass"
                />
              </span>
              <label class="col-span-3 p-4">Points on fail</label>
              <span class="col-span-9">
                <.input
                  field={@form[:points_on_fail]}
                  type="number"
                  phx-blur="save-field"
                  phx-value-target="points_on_fail"
                />
              </span>
              <label class="col-span-3 p-4">Run command</label>
              <span class="col-span-9">
                <.input
                  field={@form[:command]}
                  type="text"
                  phx-blur="save-field"
                  phx-value-target="command"
                />
              </span>
              <label class="col-span-3 p-4">Expected output</label>
              <span class="col-span-9">
                <.input
                  field={@form[:expected_output_type]}
                  type="select"
                  options={["text", "file"]}
                  prompt="Select expected output type"
                  phx-blur="save-field"
                  phx-value-target="expected_output_type"
                />
              </span>
              <span :if={@form[:expected_output_type].value == "text"} class="col-span-9 col-start-4">
                <.input
                  field={@form[:expected_output_text]}
                  type="text"
                  phx-blur="save-field"
                  phx-value-target="expected_output_text"
                />
              </span>
              <span :if={@form[:expected_output_type].value == "file"} class="col-span-9 col-start-4">
                <.input
                  field={@form[:expected_output_file]}
                  type="text"
                  placeholder="Filename"
                  phx-blur="save-field"
                  phx-value-target="expected_output_file"
                />
              </span>
            </div>
            <pre class="text-gray-700">pseudocode: if <%= @assignment_test && @assignment_test.command %> == <%= if @assignment_test.expected_output_type == "text", do: @assignment_test.expected_output_text, else: "cat(#{@assignment_test.expected_output_file})" %> then true else false</pre>
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
        name: "Lorem",
        assignment_id: socket.assigns.assignment.id,
        points_on_pass: 0,
        points_on_fail: 0,
        command: "START",
        expected_output_type: "SELECT ONE"
      }
      |> AssignmentTests.create_assignment_test()

    {:noreply,
     socket
     |> assign(:assignment_test, assignment_test)
     |> assign_form(AssignmentTests.change_assignment_test(assignment_test))}
  end

  def handle_event("validate", %{"assignment_test" => assignment_test_params}, socket) do
    changeset =
      socket.assigns.assignment_test
      |> AssignmentTests.change_assignment_test(assignment_test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("select-test", %{"id" => id}, socket) do
    assignment_test = AssignmentTests.get_assignment_test!(id)

    {:noreply,
     assign(socket, :assignment_test, assignment_test)
     |> assign_form(AssignmentTests.change_assignment_test(assignment_test))}
  end

  def handle_event("save-field", %{"value" => name, "target" => "name"}, socket) do
    save_field(socket, %{name: name})
  end

  def handle_event(
        "save-field",
        %{"value" => points_on_pass, "target" => "points_on_pass"},
        socket
      ) do
    save_field(socket, %{points_on_pass: points_on_pass})
  end

  def handle_event(
        "save-field",
        %{"value" => points_on_fail, "target" => "points_on_fail"},
        socket
      ) do
    save_field(socket, %{points_on_fail: points_on_fail})
  end

  def handle_event("save-field", %{"value" => command, "target" => "command"}, socket) do
    save_field(socket, %{command: command})
  end

  def handle_event(
        "save-field",
        %{"value" => expected_output_type, "target" => "expected_output_type"},
        socket
      ) do
    save_field(socket, %{expected_output_type: expected_output_type})
  end

  def handle_event(
        "save-field",
        %{"value" => expected_output_text, "target" => "expected_output_text"},
        socket
      ) do
    save_field(socket, %{expected_output_text: expected_output_text})
  end

  def handle_event(
        "save-field",
        %{"value" => expected_output_file, "target" => "expected_output_file"},
        socket
      ) do
    save_field(socket, %{expected_output_file: expected_output_file})
  end

  defp save_field(socket, param) do
    case AssignmentTests.update_assignment_test(socket.assigns.assignment_test, param) do
      {:ok, assignment_test} ->
        changeset = AssignmentTests.change_assignment_test(assignment_test)

        {:noreply,
         assign(socket, :assignment_test, assignment_test)
         |> assign_form(changeset)
         |> assign(
           :assignment_tests,
           AssignmentTests.list_assignment_tests_for_assignment(socket.assigns.assignment.id)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
