defmodule HandinWeb.AssignmentLive.Settings do
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
        text="Assignments"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"}
      />
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
      />
      <:item
        text="Settings"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/tests"}
        current={true}
      />
    </.tabs>

    <.header class="mt-5">
      Student Submissions
    </.header>

    <div class="grid grid-cols-6 gap-4">
      <.simple_form
        for={@form}
        id="assignment-optional-attrs"
        class="mb-4"
        phx-change="validate_and_save"
      >
        <div class="row-start-1">
          <label class="relative inline-flex items-center cursor-pointer">
            <input
              type="checkbox"
              class="sr-only peer"
              phx-click="toggle_enable_cutoff_date"
              checked={@form[:enable_cutoff_date].value}
            />
            <div class="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600">
            </div>
            <span class="ms-3 text-sm font-medium text-gray-900 dark:text-gray-300">
              &nbsp;&nbsp;Cutoff Date
            </span>
          </label>

          <div :if={@form[:enable_cutoff_date].value}>
            <.input field={@form[:cutoff_date]} type="datetime-local" />
          </div>
        </div>

        <div class="row-start-2">
          <label class="relative inline-flex items-center cursor-pointer">
            <input
              type="checkbox"
              class="sr-only peer"
              phx-click="toggle_enable_attempt_marks"
              checked={@form[:enable_attempt_marks].value}
            />
            <div class="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600">
            </div>
            <span class="ms-3 text-sm font-medium text-gray-900 dark:text-gray-300">
              &nbsp;&nbsp;Attempt Marks
            </span>
          </label>

          <div :if={@form[:enable_attempt_marks].value} class="col-span-2">
            <.input field={@form[:attempt_marks]} type="number" />
          </div>
        </div>

        <div class="row-start-3">
          <label class="relative inline-flex items-center cursor-pointer">
            <input
              type="checkbox"
              class="sr-only peer"
              phx-click="toggle_enable_penalty_per_day"
              checked={@form[:enable_penalty_per_day].value}
            />
            <div class="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600">
            </div>
            <span class="ms-3 text-sm font-medium text-gray-900 dark:text-gray-300">
              &nbsp;&nbsp;Penalty Per Day
            </span>
          </label>

          <div :if={@form[:enable_penalty_per_day].value} class="col-span-2">
            <.input field={@form[:penalty_per_day]} type="number" />
          </div>
        </div>

        <div class="row-start-4">
          <label class="relative inline-flex items-center cursor-pointer">
            <input
              type="checkbox"
              class="sr-only peer"
              phx-click="toggle_enable_max_attempts"
              checked={@form[:enable_max_attempts].value}
            />
            <div class="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600">
            </div>
            <span class="ms-3 text-sm font-medium text-gray-900 dark:text-gray-300">
              &nbsp;&nbsp;Max Attempts
            </span>
          </label>

          <div :if={@form[:enable_max_attempts].value} class="col-span-2">
            <.input field={@form[:max_attempts]} type="number" />
          </div>
        </div>

        <div class="row-start-5">
          <label class="relative inline-flex items-center cursor-pointer">
            <input
              type="checkbox"
              class="sr-only peer"
              phx-click="toggle_enable_total_marks"
              checked={@form[:enable_total_marks].value}
            />
            <div class="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600">
            </div>
            <span class="ms-3 text-sm font-medium text-gray-900 dark:text-gray-300">
              &nbsp;&nbsp;Total Marks
            </span>
          </label>

          <div :if={@form[:enable_total_marks].value} class="col-span-2">
            <.input field={@form[:total_marks]} type="number" />
          </div>
        </div>

        <div class="row-start-6">
          <label class="relative inline-flex items-center cursor-pointer">
            <input
              type="checkbox"
              class="sr-only peer"
              phx-click="toggle_enable_test_output"
              checked={@form[:enable_test_output].value}
            />
            <div class="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600">
            </div>
            <span class="ms-3 text-sm font-medium text-gray-900 dark:text-gray-300">
              &nbsp;&nbsp;Test Output
            </span>
          </label>
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    if Modules.assignment_exists?(id, assignment_id) do
      assignment = Assignments.get_assignment!(assignment_id)
      module = Modules.get_module!(id)
      changeset = Assignments.change_assignment(assignment)

      {:ok,
       socket
       |> assign(current_page: :modules)
       |> assign(:module, module)
       |> assign(:assignment, assignment)
       |> assign_form(changeset)}
    else
      {:ok,
       push_navigate(socket, to: ~p"/modules/#{id}/assignments")
       |> put_flash(:error, "You are not authorized to view this page")}
    end
  end

  @impl true
  def handle_event("toggle_" <> key, %{"value" => "on"}, socket) do
    {:ok, assignment} =
      Assignments.update_new_assignment(socket.assigns.assignment, %{"#{key}" => true})

    changeset = Assignments.change_new_assignment(assignment)

    {:noreply,
     socket
     |> assign(:assignment, assignment)
     |> assign_form(changeset)}
  end

  def handle_event("toggle_" <> key, _, socket) do
    {:ok, assignment} =
      Assignments.update_new_assignment(socket.assigns.assignment, %{"#{key}" => false})

    changeset = Assignments.change_new_assignment(assignment)

    {:noreply,
     socket
     |> assign(:assignment, assignment)
     |> assign_form(changeset)}
  end

  def handle_event("validate_and_save", %{"assignment" => assignment_params}, socket) do
    assignment =
      socket.assigns.assignment
      |> Assignments.change_assignment(assignment_params)
      |> Handin.Repo.update()

    case assignment do
      {:ok, assignment} ->
        changeset = Assignments.change_assignment(assignment)
        {:noreply, socket |> assign(:assignment, assignment) |> assign_form(changeset)}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate_and_save", _, socket) do
    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
