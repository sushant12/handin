defmodule HandinWeb.AssignmentLive.Show do
  use HandinWeb, :live_view

  alias Handin.Modules

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: :modules)
     |> assign(:module, Modules.get_module!(id))}
  end
end
