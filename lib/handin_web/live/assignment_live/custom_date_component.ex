defmodule HandinWeb.AssignmentLive.CustomDateComponent do
  use HandinWeb, :live_component

  alias Handin.{Assignments, Modules}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="custom_assignment_date-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="mt-2"
      >
        <.input
          field={@form[:user_id]}
          type="select"
          label="User"
          options={Enum.map(@students, &{&1.email, &1.id})}
          prompt="Select User"
          required
        />

        <.input field={@form[:start_date]} type="datetime-local" label="Start date" />

        <.input field={@form[:due_date]} type="datetime-local" label="Due date" />

        <.input type="checkbox" field={@form[:enable_cutoff_date]} label="Enable Cutoff Date" />
        <.input
          :if={Phoenix.HTML.Form.normalize_value("checkbox", @form[:enable_cutoff_date].value)}
          field={@form[:cutoff_date]}
          type="datetime-local"
          label="Cut Off date"
        />

        <:actions>
          <.button
            class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
            phx-disable-with="Saving..."
          >
            Save
          </.button>
          <.link
            patch={@patch}
            class="text-red-600 inline-flex items-center hover:text-white border border-red-600 hover:bg-red-600 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-red-500 dark:text-red-500 dark:hover:text-white dark:hover:bg-red-600 dark:focus:ring-red-900"
          >
            Cancel
          </.link>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(
        %{custom_assignment_date: custom_assignment_date, module_id: module_id} = assigns,
        socket
      ) do
    changeset = Assignments.change_custom_assignment_date(custom_assignment_date)
    students = Modules.get_students(module_id)
    {:ok, socket |> assign(assigns) |> assign_form(changeset) |> assign(:students, students)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"custom_assignment_date" => custom_assignment_date_params},
        socket
      ) do
    changeset =
      socket.assigns.custom_assignment_date
      |> Assignments.change_custom_assignment_date(
        Map.put(
          custom_assignment_date_params,
          "timezone",
          socket.assigns.current_user.university.timezone
        )
      )
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"custom_assignment_date" => custom_assignment_date_params}, socket) do
    save_custom_assignment_date(
      socket,
      socket.assigns.action,
      custom_assignment_date_params
      |> Map.put("timezone", socket.assigns.current_user.university.timezone)
      |> Map.put("assignment_id", socket.assigns.assignment.id)
    )
  end

  defp save_custom_assignment_date(
         socket,
         :add_custom_assignment_date,
         custom_assignment_date_params
       ) do
    case Assignments.create_custom_assignment_date(custom_assignment_date_params) do
      {:ok, custom_assignment_date} ->
        notify_parent({:saved, custom_assignment_date})

        {:noreply,
         socket
         |> put_flash(:info, "Custom date created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_custom_assignment_date(
         socket,
         :edit_custom_assignment_date,
         custom_assignment_date_params
       ) do
    case Assignments.update_custom_assignment_date(
           socket.assigns.custom_assignment_date,
           custom_assignment_date_params
         ) do
      {:ok, custom_assignment_date} ->
        notify_parent({:saved, custom_assignment_date})

        {:noreply,
         socket
         |> put_flash(:info, "Custom date updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
