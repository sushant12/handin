defmodule HandinWeb.AssignmentLive.Tests do
  use HandinWeb, :live_view

  alias Handin.Modules
  alias Handin.Assignments
  @impl true
  def render(assigns) do
    ~H"""
    <.breadcrumbs>
      <:item text="Home" href={~p"/"} />
      <:item text="Modules" href={~p"/modules"} />
      <:item text={@module.name} href={~p"/modules/#{@module.id}/assignments"} />
      <:item
        text="Assignments"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}"}
        current={true}
      />
    </.breadcrumbs>

    <.tabs>
      <:item text="Details" href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"} />
      <:item
        text="Environment"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/environment"}
      />
      <:item
        text="Tests"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/tests"}
        current={true}
      />
      <:item
        text="Submissions"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/submissions"}
      />
    </.tabs>
    """
  end

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: :modules)
     |> assign(:module, Modules.get_module!(id))
     |> assign(:assignment, Assignments.get_assignment!(assignment_id))}
  end
end
