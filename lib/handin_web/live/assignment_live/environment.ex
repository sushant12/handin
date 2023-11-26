defmodule HandinWeb.AssignmentLive.Environment do
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
     |> assign(:assignment, assignment)
     |> assign(:form, Assignments.change_assignment(assignment) |> to_form())
     |> assign(
       :programming_languages,
       ProgrammingLanguages.list_programming_languages() |> Enum.map(&{&1.name, &1.id})
     )
     |> LiveMonacoEditor.set_value(assignment.name)}
  end
end
