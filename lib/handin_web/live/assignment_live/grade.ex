defmodule HandinWeb.AssignmentLive.Grade do
  use HandinWeb, :live_view

  alias Handin.{Assignments, Accounts, Modules}

  @impl true
  def render(assigns) do
    ~H"""
    <.breadcrumbs>
      <:item text="Home" href={~p"/"} />
      <:item text="Modules" href={~p"/modules"} />
      <:item text={@module.name} href={~p"/modules/#{@module.id}/grades"} current={true} />
    </.breadcrumbs>
    <.tabs>
      <:item text="Assignments" href={~p"/modules/#{@module.id}/assignments"} />
      <:item text="Students" href={~p"/modules/#{@module.id}/students"} />
      <:item text="Teaching Assistants" href={~p"/modules/#{@module.id}/teaching_assistants"} />

      <:item text="Grades" href={~p"/modules/#{@module.id}/grades"} current={true} />
    </.tabs>

    <.table id="assignment_submissions" rows={@streams.assignment_submissions}>
      <:col :let={{_id, assignment_submission}} label="Name">
        {assignment_submission.assignment.name}
      </:col>
      <:col :let={{_id, assignment_submission}} label="Total marks">
        {assignment_submission.total_points} / {assignment_submission.assignment.total_marks}
      </:col>
    </.table>
    """
  end

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    if Accounts.enrolled_module?(socket.assigns.current_user, id) ||
         socket.assigns.current_user.role in [:admin, :teaching_assistant] do
      module = Modules.get_module!(id)

      assignment_submissions =
        Assignments.get_submissions_for_user(id, socket.assigns.current_user.id)

      {:ok,
       socket
       |> stream(:assignment_submissions, assignment_submissions)
       |> assign(:module, module)
       |> assign(:current_page, :grades)}
    else
      {:ok,
       push_navigate(socket, to: ~p"/modules")
       |> put_flash(:error, "You are not authorized to view this page")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Grades")
    |> assign(:current_tab, :assignments)
  end
end
