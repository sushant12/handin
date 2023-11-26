defmodule HandinWeb.AssignmentLive.Submission do
  use HandinWeb, :live_view

  alias Handin.Modules
  alias Handin.Assignments
  alias Handin.ProgrammingLanguages

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    assignment = Assignments.get_assignment!(assignment_id)
    module = Modules.get_module!(id)

    {:ok,
     socket
     |> assign(current_page: :modules)
     |> assign(:module, module)
     |> assign(:assignment, assignment)}
  end
end
