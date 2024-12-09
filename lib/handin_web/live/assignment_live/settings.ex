defmodule HandinWeb.AssignmentLive.Settings do
  use HandinWeb, :live_view

  alias Handin.{Modules, Assignments}
  alias Handin.Assignments.CustomAssignmentDate

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

      <.input
        :if={Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_cutoff_date].value)}
        type="checkbox"
        field={@form[:enable_penalty_per_day]}
        label="Enable Penalty Per Day"
      />
      <div
        :if={
          Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_cutoff_date].value) &&
            Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_penalty_per_day].value)
        }
        class="flex items-end"
      >
        <div class="w-64">
          <.input field={@form[:penalty_per_day]} type="number" />
        </div>
        <span class="text-sm ml-2 mb-2 whitespace-nowrap">(in percentage)</span>
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

      <.input
        :if={Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_total_marks].value)}
        type="checkbox"
        field={@form[:enable_attempt_marks]}
        label="Enable Attempt Marks"
      />
      <div class="w-64">
        <.input
          :if={
            Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_total_marks].value) &&
              Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_attempt_marks].value)
          }
          field={@form[:attempt_marks]}
          type="number"
        />
      </div>

      <.input type="checkbox" field={@form[:enable_test_output]} label="Show Test Output to Students" />
      <div class="w-64">
        <.input type="number" field={@form[:cpu]} label="CPU" />
        <.input type="number" field={@form[:memory]} label="Memory" />
      </div>
      <.button
        class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
        phx-disable-with="Saving..."
      >
        Save
      </.button>
      <.link
        class="text-white inline-flex items-center bg-green-700 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800 mb-4"
        patch={
          ~p"/modules/#{@module.id}/assignments/#{@assignment.id}/settings/add_custom_assignment_date"
        }
      >
        Add Custom Dates
      </.link>
    </.simple_form>
    <.table id="custom_assignment_dates" rows={@streams.custom_assignment_dates}>
      <:col :let={{_id, custom_assignment_date}} label="Email">
        <%= custom_assignment_date.user.email %>
      </:col>
      <:col :let={{_id, custom_assignment_date}} label="Start Date">
        <%= Handin.DisplayHelper.format_date(custom_assignment_date.start_date) %>
      </:col>
      <:col :let={{_id, custom_assignment_date}} label="Due Date">
        <%= Handin.DisplayHelper.format_date(custom_assignment_date.due_date) %>
      </:col>
      <:col :let={{_id, custom_assignment_date}} label="Cutoff Date">
        <%= if custom_assignment_date.enable_cutoff_date,
          do: Handin.DisplayHelper.format_date(custom_assignment_date.cutoff_date) %>
      </:col>
      <:action :let={{id, custom_assignment_date}}>
        <.link
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
          patch={
            ~p"/modules/#{@module.id}/assignments/#{@assignment.id}/settings/edit_custom_assignment_date/#{custom_assignment_date.id}"
          }
        >
          Edit
        </.link>
        <.link
          class="text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 focus:outline-none dark:focus:ring-red-800"
          phx-click={
            JS.push("delete", value: %{id: custom_assignment_date.id})
            |> hide("##{id}")
          }
          data-confirm="Remove custom assignment date?"
        >
          Remove
        </.link>
      </:action>
    </.table>
    <.modal
      :if={@live_action in [:add_custom_assignment_date, :edit_custom_assignment_date]}
      id="custom_assignment_dates-modal"
      show
      on_cancel={JS.patch(~p"/modules/#{@module.id}/assignments/#{@assignment.id}/settings")}
    >
      <.live_component
        module={HandinWeb.AssignmentLive.CustomDateComponent}
        title={@page_title}
        id={@assignment.id}
        action={@live_action}
        module_id={@module.id}
        assignment={@assignment}
        custom_assignment_date={@custom_assignment_date}
        current_user={@current_user}
        patch={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/settings"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    user = socket.assigns.current_user

    with {:ok, module} <- Modules.get_module(id),
         {:ok, _module_user} <-
           Modules.module_user(module, user),
         {:ok, assignment} <- Assignments.get_assignment(assignment_id, module.id) do
      {:ok,
       socket
       |> assign(current_page: :modules)
       |> assign(:page_title, "#{module.name} - #{assignment.name}")
       |> assign(:module, module)
       |> assign(:assignment, assignment)
       |> stream(
         :custom_assignment_dates,
         Assignments.list_custom_assignment_dates(assignment_id)
       )
       |> assign_form(Assignments.change_assignment(assignment))}
    else
      {:error, reason} ->
        {:ok,
         push_navigate(socket, to: ~p"/modules/#{id}/assignments")
         |> put_flash(:error, reason)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :add_custom_assignment_date, _) do
    socket
    |> assign(:page_title, "Add Custom Date")
    |> assign(:custom_assignment_date, %CustomAssignmentDate{})
  end

  defp apply_action(socket, :edit_custom_assignment_date, %{
         "id" => id,
         "assignment_id" => assignment_id,
         "custom_assignment_date_id" => custom_assignment_date_id
       }) do
    custom_assignment_date =
      Assignments.get_custom_assignment_date(custom_assignment_date_id)

    if custom_assignment_date.assignment_id == assignment_id do
      socket
      |> assign(:page_title, "Edit Custom Date")
      |> assign(:custom_assignment_date, custom_assignment_date)
    else
      push_navigate(socket, to: ~p"/modules/#{id}/assignments")
      |> put_flash(:error, "You are not authorized to view this page")
    end
  end

  defp apply_action(socket, _, _) do
    socket
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

  def handle_event("delete", %{"id" => custom_assignment_date_id}, socket) do
    custom_assignment_date =
      custom_assignment_date_id
      |> Assignments.get_custom_assignment_date()
      |> Assignments.delete_custom_assignment_date!()

    {:noreply, socket |> stream_delete(:custom_assignment_dates, custom_assignment_date)}
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

  @impl true
  def handle_info(
        {HandinWeb.AssignmentLive.CustomDateComponent, {:saved, custom_assignment_date}},
        socket
      ) do
    {:noreply,
     stream_insert(
       socket,
       :custom_assignment_dates,
       Assignments.get_custom_assignment_date(custom_assignment_date.id)
     )}
  end
end
