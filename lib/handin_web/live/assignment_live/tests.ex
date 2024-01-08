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
            <li
              :for={solution_file <- @assignment.solution_files}
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
                class={[
                  "py-1 relative flex justify-between items-center hover:bg-gray-200 dark:hover:bg-gray-700 p-2 rounded",
                  test.id == @assignment_test.id && "bg-gray-300"
                ]}
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
      <div class="ml-8">
        <div class="rounded shadow-md px-4 mb-4">
          <.simple_form :if={@assignment_test} for={@form} phx-change="validate" phx-submit="save">
            <.input field={@form[:name]} type="text" label="Name" />
            <%= if @assignment.enable_total_marks do %>
              <.input field={@form[:points_on_pass]} type="number" label="Points on Pass" />
              <.input field={@form[:points_on_fail]} type="number" label="Points on Fail" />
            <% end %>
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
              type="text"
              label="File Name"
            />
            <.input
              :if={@form[:expected_output_type].value in [:string, "string"]}
              field={@form[:expected_output_text]}
              type="text"
              label="Expected Text"
            />

            <.button
              class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
              phx-disable-with="Saving..."
            >
              Save
            </.button>
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
            disabled={@build && @build.status == "running"}
          >
            <%= if @build, do: "Running", else: "Run All Tests" %>
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
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    if Modules.assignment_exists?(id, assignment_id) do
      assignment = Assignments.get_assignment!(assignment_id)
      assignment_test = Enum.at(assignment.assignment_tests, 0)
      module = Modules.get_module!(id)

      {:ok,
       socket
       |> assign(current_page: :modules)
       |> assign(:module, module)
       |> assign(:page_title, "#{module.name} - #{assignment.name}")
       |> assign(:assignment, assignment)
       |> assign(:assignment_test, assignment_test)
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
       |> assign_form(
         AssignmentTests.change_assignment_test(
           assignment_test || %AssignmentTest{assignment_id: assignment.id}
         )
       )}
    else
      {:ok,
       push_navigate(socket, to: ~p"/modules/#{id}/assignments")
       |> put_flash(:error, "You are not authorized to view this page")}
    end
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

  def handle_event("save", %{"assignment_test" => assignment_test_params}, socket) do
    save_assignment_test(socket, :edit, assignment_test_params)
  end

  # def handle_event("update_name", %{"value" => value}, socket) do
  #   {:ok, assignment_test} =
  #     Handin.Assignments.AssignmentTest.new_changeset(socket.assigns.assignment_test, %{
  #       name: value
  #     })
  #     |> Repo.update()

  #   assignment = socket.assigns.assignment |> Repo.preload(:assignment_tests, force: true)

  #   {:noreply,
  #    assign(socket, :assignment_test, assignment_test)
  #    |> assign(
  #      :assignment_tests,
  #      assignment.assignment_tests
  #    )}
  # end

  # def handle_event("update_expected_output_file", %{"value" => value}, socket) do
  #   socket.assigns.assignment_test
  #   |> Repo.preload(assignment: [:support_files])
  #   |> Handin.Assignments.AssignmentTest.output_file_changeset(%{
  #     expected_output_file: value
  #   })
  #   |> Repo.update()
  #   |> case do
  #     {:ok, assignment_test} ->
  #       {:noreply, assign(socket, :assignment_test, assignment_test)}

  #     {:error, changeset} ->
  #       {:noreply, assign_form(socket, changeset)}
  #   end
  # end

  # def handle_event("update_" <> key, %{"value" => value}, socket) do
  #   {:ok, assignment_test} =
  #     Handin.Assignments.AssignmentTest.new_changeset(socket.assigns.assignment_test, %{
  #       "#{key}": value
  #     })
  #     |> Repo.update()

  #   {:noreply, assign(socket, :assignment_test, assignment_test)}
  # end

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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp save_assignment_test(socket, :edit, assignment_test_params) do
    case Assignments.update_assignment_test(
           socket.assigns.assignment_test,
           assignment_test_params
         ) do
      {:ok, assignment_test} ->
        {:noreply,
         socket
         |> assign_form(Assignments.change_assignment_test(assignment_test))
         |> put_flash(:info, "Test saved successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
