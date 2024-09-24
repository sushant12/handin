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
        text={@assignment.name}
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"}
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
      <:item text="Settings" href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/settings"} />
    </.tabs>

    <div>
      <.form
        for={%{}}
        action={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/download"}
        method="post"
      >
        <button
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 text-center mr-3 mb-5"
          type="submit"
        >
          Download Submission Details
        </button>
      </.form>
    </div>

    <.table id="submitted_assignment_submissions" rows={@assignment_submissions}>
      <:col :let={{_, i}} label="id">
        <%= i %>
      </:col>
      <:col :let={{submission, _}} label="email">
        <%= submission.user.email %>
      </:col>
      <:col :let={{submission, _}} :if={@assignment.enable_total_marks} label="Total marks">
        <%= submission.total_points %> / <%= @assignment.total_marks %>
      </:col>
      <:col :let={{submission, _}} label="Submitted At">
        <%= Handin.DisplayHelper.format_date(submission.submitted_at) %>
      </:col>
      <:action :let={{submission, _}}>
        <.link
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 text-center mr-3 md:mr-0 mt-3"
          href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/submission/#{submission.id}"}
        >
          Show
        </.link>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    if Modules.assignment_exists?(id, assignment_id) do
      assignment = Assignments.get_assignment!(assignment_id)
      module = Modules.get_module!(id)

      assignment_submissions =
        Assignments.get_submissions_for_assignment(assignment_id) |> Enum.with_index(1)

      {:ok,
       socket
       |> assign(current_page: :modules)
       |> assign(:module, module)
       |> assign(:assignment, assignment)
       |> assign(:assignment_submissions, assignment_submissions)
       |> assign(:page_title, "#{module.name} - #{assignment.name}")}
    else
      {:ok,
       push_navigate(socket, to: ~p"/modules/#{id}/assignments")
       |> put_flash(:error, "You are not authorized to view this page")}
    end
  end
end
