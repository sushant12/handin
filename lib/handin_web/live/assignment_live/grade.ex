defmodule HandinWeb.AssignmentLive.Grade do
  use HandinWeb, :live_view

  alias Handin.{Assignments, Accounts}

  @impl true
  def render(assigns) do
    ~H"""
    <.tabs>
      <:item text="Assignments" href={~p"/modules/#{@module_id}/assignments"} />
      <:item text="Members" href={~p"/modules/#{@module_id}/members"} />
      <:item text="Grades" href={~p"/modules/#{@module_id}/grades"} current={true} />
    </.tabs>

    <.table id="assignment_submissions" rows={@streams.assignment_submissions}>
      <:col :let={{_id, assignment_submission}} label="Name">
        <%= assignment_submission.assignment.name %>
      </:col>
      <:col :let={{_id, assignment_submission}} label="Total marks">
        <%= assignment_submission.total_points %> / <%= assignment_submission.assignment.total_marks %>
      </:col>
    </.table>
    """
  end

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    if Accounts.enrolled_module?(socket.assigns.current_user, id) do
      assignment_submissions =
        Assignments.get_submissions_for_user(id, socket.assigns.current_user.id)

      {:ok,
       socket
       |> stream(:assignment_submissions, assignment_submissions)
       |> assign(:module_id, id)
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
