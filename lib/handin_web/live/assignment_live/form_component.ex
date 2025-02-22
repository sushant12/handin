defmodule HandinWeb.AssignmentLive.FormComponent do
  use HandinWeb, :live_component

  alias Handin.Assignments

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="assignment-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:start_date]} type="datetime-local" label="Start date" />
        <.input field={@form[:due_date]} type="datetime-local" label="Due date" />
        <.input
          :if={@form[:enable_cutoff_date].value}
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
  def update(%{assignment: assignment} = assigns, socket) do
    changeset = Assignments.change_assignment(assignment)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"assignment" => assignment_params}, socket) do
    changeset =
      socket.assigns.assignment
      |> Assignments.change_assignment(
        Map.put(assignment_params, "timezone", Handin.get_timezone())
      )
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"assignment" => assignment_params}, socket) do
    save_assignment(
      socket,
      socket.assigns.action,
      Map.put(assignment_params, "module_id", socket.assigns.module_id)
      |> Map.put("timezone", Handin.get_timezone())
    )
  end

  defp save_assignment(socket, :edit, assignment_params) do
    case Assignments.update_assignment(socket.assigns.assignment, assignment_params) do
      {:ok, assignment} ->
        notify_parent({:saved, assignment})

        {:noreply,
         socket
         |> put_flash(:info, "Assignment updated successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_assignment(socket, :new, assignment_params) do
    case Assignments.create_assignment(assignment_params) do
      {:ok, assignment} ->
        notify_parent({:saved, assignment})

        {:noreply,
         socket
         |> put_flash(:info, "Assignment created successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
