defmodule HandinWeb.AssignmentLive.Index do
  use HandinWeb, :live_view

  alias Handin.{Assignments, Modules, ProgrammingLanguages, Accounts}
  alias Handin.Assignments.Assignment

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    with true <- Accounts.enrolled_module?(socket.assigns.current_user, id),
         assignments <-
           Modules.list_assignments_for(id, socket.assigns.current_user.role) do
      programming_languages =
        ProgrammingLanguages.list_programming_languages() |> Enum.map(&{&1.name, &1.id})

      {:ok,
       socket
       |> stream(:assignments, assignments)
       |> assign(:programming_languages, programming_languages)
       |> assign(:module_id, id)
       |> assign(:current_page, :modules)}
    else
      false ->
        {:ok,
         push_navigate(socket, to: ~p"/modules")
         |> put_flash(:error, "You are not authorized to view this page")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"assignment_id" => assignment_id}) do
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
    |> assign(:page_title, "Assignments")
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

    {:noreply,
     stream_delete(socket, :assignments, assignment)
     |> put_flash(:info, "Assignment deleted successfully")}
  end
end
