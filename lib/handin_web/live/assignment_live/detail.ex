defmodule HandinWeb.AssignmentLive.Detail do
  use HandinWeb, :live_view

  alias Handin.Modules
  alias Handin.Assignments

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: :modules)
     |> assign(:module, Modules.get_module!(id))
     |> assign(:assignment, Assignments.get_assignment!(assignment_id))}
  end
end
