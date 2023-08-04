defmodule HandinWeb.AssignmentLive.Index do
  use HandinWeb, :live_view

  alias Handin.{Assignments, Repo, Modules}
  alias Handin.Assignments.Assignment

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    %{assignments: assignments} = Modules.get_module!(id) |> Repo.preload(:assignments)

    {:ok,
     socket
     |> stream(:assignments, assignments)
     |> assign(:module_id, id)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => _id, "assignment_id" => assignment_id}) do
    socket
    |> assign(:page_title, "Edit Assignment")
    |> assign(:assignment, Assignments.get_assignment!(assignment_id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Assignment")
    |> assign(:assignment, %Assignment{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Assignments")
    |> assign(:assignment, nil)
    |> assign(:current_tab, :assignments)
  end

  @impl true
  def handle_info({HandinWeb.AssignmentLive.FormComponent, {:saved, assignment}}, socket) do
    {:noreply, stream_insert(socket, :assignments, assignment)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    assignment = Assignments.get_assignment!(id)
    {:ok, _} = Assignments.delete_assignment(assignment)

    {:noreply, stream_delete(socket, :assignments, assignment)}
  end
end
