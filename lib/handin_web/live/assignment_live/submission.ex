defmodule HandinWeb.AssignmentLive.Submission do
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
      <:item text="Tests" href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/tests"} />
      <:item
        text="Submissions"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/submissions"}
        current={true}
      />
    </.tabs>

    <.header class="mt-5">
      Student Submissions
    </.header>
    <.table id="submitted_assignment_submissions" rows={@assignment.assignment_submissions}>
      <:col :let={{_, i}} label="id">
        <%= i %>
      </:col>
      <:col :let={{submission, _}} label="email">
        <%= submission.user.email %>
      </:col>
      <:action :let={{submission, _}}>
        <.link
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 text-center mr-3 md:mr-0 mt-3"
          href={~p"/modules/#{@module_id}/assignments/#{@assignment.id}/submission/#{submission.id}"}
          target="_blank"
        >
          Show
        </.link>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    assignment = Assignments.get_assignment!(assignment_id)
    module = Modules.get_module!(id)

    {:ok,
     socket
     |> assign(current_page: :modules)
     |> assign(:module, module)
     |> assign(:page_title, "#{module.name} - #{assignment.name}")
     |> assign(:assignment, assignment)}
  end
end
