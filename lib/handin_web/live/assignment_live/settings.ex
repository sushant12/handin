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

    <.simple_form
      for={@form}
      id="assignment-optional-attrs"
      class="mb-4"
      phx-change="validate"
      phx-submit="save"
    >
      <.input type="checkbox" field={@form[:enable_cutoff_date]} label="Enable Cutoff Date" />
      <div class="w-64">
        <.input
          :if={Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_cutoff_date].value)}
          field={@form[:cutoff_date]}
          type="datetime-local"
        />
      </div>

      <.input type="checkbox" field={@form[:enable_attempt_marks]} label="Enable Attempt Marks" />
      <div class="w-64">
        <.input
          :if={Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_attempt_marks].value)}
          field={@form[:attempt_marks]}
          type="number"
        />
      </div>
      <.input
        :if={Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_cutoff_date].value)}
        type="checkbox"
        field={@form[:enable_penalty_per_day]}
        label="Enable Penalty Per Day"
      />
      <div class="w-64">
        <.input
          :if={Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_penalty_per_day].value)}
          field={@form[:penalty_per_day]}
          type="number"
        />
      </div>
      <.input type="checkbox" field={@form[:enable_max_attempts]} label="Enable Max Attempts" />
      <div class="w-64">
        <.input
          :if={Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_max_attempts].value)}
          field={@form[:max_attempts]}
          type="number"
        />
      </div>
      <.input type="checkbox" field={@form[:enable_total_marks]} label="Enable Total Marks" />

      <div class="w-64">
        <.input
          :if={Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_total_marks].value)}
          field={@form[:total_marks]}
          type="number"
        />
      </div>
      <.input type="checkbox" field={@form[:enable_test_output]} label="Show Test Output to Students" />
      <.button
        class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
        phx-disable-with="Saving..."
      >
        Save
      </.button>
    </.simple_form>
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
       |> assign(:page_title, "#{module.name} - #{assignment.name}")
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
  def handle_event("validate", %{"assignment" => assignment_params}, socket) do
    changeset =
      socket.assigns.assignment
      |> Assignments.change_assignment(assignment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"assignment" => assignment_params}, socket) do
    save_assignment(socket, :edit, assignment_params)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp save_assignment(socket, :edit, assignment_params) do
    case Assignments.update_assignment(socket.assigns.assignment, assignment_params) do
      {:ok, assignment} ->
        {:noreply,
         socket
         |> assign_form(Assignments.change_assignment(assignment))
         |> put_flash(:info, "Assignment updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
