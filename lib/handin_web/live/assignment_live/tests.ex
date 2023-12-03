defmodule HandinWeb.AssignmentLive.Tests do
  use HandinWeb, :live_view

  alias Handin.Modules
  alias Handin.Assignments
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
      <div class="bg-gray-200 p-4 w-[180px] h-[75vh]">
        <div class="assignment-test-files">
          <ul>
            <li class="py-1 flex items-center">
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
              <span class="truncate hover:text-clip wrap-text w-[50px]" title="sum.cc">sum.cc</span>
            </li>
            <li class="py-1 flex items-center">
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
              <span class="truncate hover:text-clip wrap-text w-[50px]" title="m1.in">m1.in</span>
            </li>
          </ul>
        </div>
        <div class="border-t border-gray-300 mt-4 pt-4">
          <div class="assignment-test-tests">
            <ul>
              <li class="py-1 relative flex justify-between items-center">
                <a href="#">sum two numbers</a>
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
      <div class="assignment-test-container flex-1 p-4">
        <div class="assignment-test-form bg-white rounded shadow-md p-4 mb-4 h-64 w-full">
          <.simple_form for={@form} id="test-creation-form" class="mb-4">
            <.input field={@form[:name]} label="Name" type="text" />
            <.input field={@form[:name]} label="Name" type="text" />
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

    {:ok,
     socket
     |> assign(current_page: :modules)
     |> assign(:module, Modules.get_module!(id))
     |> assign(:assignment, assignment)
     |> assign(:form, Assignments.change_assignment(assignment) |> to_form())}
  end
end
