defmodule HandinWeb.AssignmentLive.FormComponent do
  use HandinWeb, :live_component

  alias Handin.Assignments

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage assignment records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="assignment-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:total_marks]} type="number" label="Total marks" />
        <.input field={@form[:start_date]} type="datetime-local" label="Start date" />
        <.input field={@form[:due_date]} type="datetime-local" label="Due date" />
        <.input field={@form[:cutoff_date]} type="datetime-local" label="Cutoff date" />
        <.input field={@form[:max_attempts]} type="number" label="Max attempts" />
        <.input field={@form[:penalty_per_day]} type="number" label="Penalty per day" step="any" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Assignment</.button>
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
      |> Assignments.change_assignment(assignment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"assignment" => assignment_params}, socket) do
    save_assignment(
      socket,
      socket.assigns.action,
      assignment_params |> Map.put("module_id", socket.assigns.module_id)
    )
  end

  defp save_assignment(socket, :edit, assignment_params) do
    case Assignments.update_assignment(socket.assigns.assignment, assignment_params) do
      {:ok, assignment} ->
        notify_parent({:saved, assignment})

        {:noreply,
         socket
         |> put_flash(:info, "Assignment updated successfully")
         |> push_patch(to: socket.assigns.patch)}

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
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
