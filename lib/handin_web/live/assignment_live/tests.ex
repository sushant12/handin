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

    <div class="flex h-screen">
      <div class="bg-gray-50 dark:bg-gray-800 p-4 w-64 h-full p-4">
        <div class="assignment-test-files">
          <ul>
            <li
              :if={@assignment.support_files == [] && @assignment.solution_files == []}
              class="py-1 flex items-center"
            >
              No files added
            </li>
            <li :for={support_file <- @assignment.support_files} class="py-1 flex items-center">
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
              <span class="truncate" title={support_file.file.file_name}>
                <%= support_file.file.file_name %>
              </span>
            </li>
            <li :for={solution_file <- @assignment.solution_files} class="py-1 flex items-center">
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

              <span class="truncate" title={solution_file.file.file_name}>
                <%= solution_file.file.file_name %>
              </span>
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
                class="py-1 relative flex justify-between items-center hover:bg-gray-200 dark:hover:bg-gray-700"
              >
                <.link
                  phx-click="select-test"
                  phx-value-id={test.id}
                  class="truncate"
                  title={test.name}
                >
                  <%= test.name %>
                </.link>

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
      <div class="flex-1 ml-4">
        <div class="assignment-test-form bg-white rounded shadow-md px-4 mb-4  w-full">
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
              <label class="col-span-3 p-4">TTL</label>
              <span class="col-span-9">
                <.input field={@form[:ttl]} type="number" />
              </span>
            </div>
            <pre>
              pseudocode: if <span class="text-blue-500"><%=  @assignment_test.command %></span> == <span class="text-blue-500"><%= if @assignment_test.expected_output_type == "file", do: "cat(#{@assignment_test.expected_output_file})", else: @assignment_test.expected_output_text %> </span> then <span class="text-green-500"> true </span> else <span class="text-red-600">false</span></pre>
          </.simple_form>
        </div>
        <div class="flex">
          <button
            type="button"
            class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
            phx-click="run_tests"
            phx-value-assignment_id={@assignment.id}
          >
            Run All Tests
          </button>
        </div>

        <div id="accordion-open" data-accordion="open">
          <h2 id="accordion-open-heading-1">
            <button
              type="button"
              class="flex items-center justify-between w-full p-5 font-medium rtl:text-right text-green-500 border border-b-0 border-gray-200 rounded-t-xl focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-800 dark:border-gray-700 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 gap-3"
              data-accordion-target="#accordion-open-body-1"
              aria-expanded="true"
              aria-controls="accordion-open-body-1"
            >
              <span class="flex items-center">
                <svg
                  class="w-6 h-6 text-green-500 dark:text-white"
                  aria-hidden="true"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 8.207-4 4a1 1 0 0 1-1.414 0l-2-2a1 1 0 0 1 1.414-1.414L9 10.586l3.293-3.293a1 1 0 0 1 1.414 1.414Z" />
                </svg>
                What is Flowbite?
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
          <div id="accordion-open-body-1" class="hidden" aria-labelledby="accordion-open-heading-1">
            <div class="p-5 border border-b-0 border-gray-200 dark:border-gray-700 dark:bg-gray-900">
              <p class="font-semibold">Expected Output:</p>
              <p class="mb-2 text-gray-500 dark:text-gray-400">
                Flowbite is an open-source library of interactive components built on top of Tailwind CSS including buttons, dropdowns, modals, navbars, and more.
              </p>
              <p class="font-semibold">Got:</p>
              <p class="text-gray-500 dark:text-gray-400">
                Check out this guide to learn how to
                <a
                  href="/docs/getting-started/introduction/"
                  class="text-blue-600 dark:text-blue-500 hover:underline"
                >
                  get started
                </a>
                and start developing websites even faster with components on top of Tailwind CSS.
              </p>
            </div>
          </div>
          <h2 id="accordion-open-heading-2">
            <button
              type="button"
              class="flex items-center justify-between w-full p-5 font-medium rtl:text-right text-red-600 border border-b-0 border-gray-200 focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-800 dark:border-gray-700 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 gap-3"
              data-accordion-target="#accordion-open-body-2"
              aria-expanded="false"
              aria-controls="accordion-open-body-2"
            >
              <span class="flex items-center">
                <svg
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
                Is there a Figma file available?
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
          <div id="accordion-open-body-2" class="hidden" aria-labelledby="accordion-open-heading-2">
            <div class="p-5 border border-b-0 border-gray-200 dark:border-gray-700">
              <p class="mb-2 text-gray-500 dark:text-gray-400">
                Flowbite is first conceptualized and designed using the Figma software so everything you see in the library has a design equivalent in our Figma file.
              </p>
              <p class="text-gray-500 dark:text-gray-400">
                Check out the
                <a
                  href="https://flowbite.com/figma/"
                  class="text-blue-600 dark:text-blue-500 hover:underline"
                >
                  Figma design system
                </a>
                based on the utility classes from Tailwind CSS and components from Flowbite.
              </p>
            </div>
          </div>
          <h2 id="accordion-open-heading-3">
            <button
              type="button"
              class="flex items-center justify-between w-full p-5 font-medium rtl:text-right text-gray-500 border border-gray-200 focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-800 dark:border-gray-700 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 gap-3"
              data-accordion-target="#accordion-open-body-3"
              aria-expanded="false"
              aria-controls="accordion-open-body-3"
            >
              <span class="flex items-center">
                <svg
                  class="w-5 h-5 me-2 shrink-0"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    fill-rule="evenodd"
                    d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z"
                    clip-rule="evenodd"
                  >
                  </path>
                </svg>
                What are the differences between Flowbite and Tailwind UI?
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
          <div id="accordion-open-body-3" class="hidden" aria-labelledby="accordion-open-heading-3">
            <div class="p-5 border border-t-0 border-gray-200 dark:border-gray-700">
              <p class="mb-2 text-gray-500 dark:text-gray-400">
                The main difference is that the core components from Flowbite are open source under the MIT license, whereas Tailwind UI is a paid product. Another difference is that Flowbite relies on smaller and standalone components, whereas Tailwind UI offers sections of pages.
              </p>
              <p class="mb-2 text-gray-500 dark:text-gray-400">
                However, we actually recommend using both Flowbite, Flowbite Pro, and even Tailwind UI as there is no technical reason stopping you from using the best of two worlds.
              </p>
              <p class="mb-2 text-gray-500 dark:text-gray-400">
                Learn more about these technologies:
              </p>
              <ul class="ps-5 text-gray-500 list-disc dark:text-gray-400">
                <li>
                  <a
                    href="https://flowbite.com/pro/"
                    class="text-blue-600 dark:text-blue-500 hover:underline"
                  >
                    Flowbite Pro
                  </a>
                </li>
                <li>
                  <a
                    href="https://tailwindui.com/"
                    rel="nofollow"
                    class="text-blue-600 dark:text-blue-500 hover:underline"
                  >
                    Tailwind UI
                  </a>
                </li>
              </ul>
            </div>
          </div>
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
     |> assign(:logs, Assignments.get_recent_build_logs(assignment_id))
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

  def handle_event("run_tests", %{"assignment_id" => assignment_id}, socket) do
    HandinWeb.Endpoint.subscribe("build:assignment_tests:#{assignment_id}")

    DynamicSupervisor.start_child(Handin.BuildSupervisor, %{
      id: Handin.BuildServer,
      start:
        {Handin.BuildServer, :start_link,
         [
           %{
             assignment_id: assignment_id,
             type: "assignment_tests",
             image: socket.assigns.assignment.programming_language.docker_file_url
           }
         ]},
      restart: :temporary
    })

    {:noreply, assign(socket, :logs, [])}
  end

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
