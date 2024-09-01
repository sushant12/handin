defmodule HandinWeb.AssignmentLive.Index do
  use HandinWeb, :live_view

  alias Handin.{Assignments, Modules, ProgrammingLanguages}
  alias Handin.Assignments.Assignment

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    user = socket.assigns.current_user

    with {:ok, module} <- Modules.get_module(id),
         {:ok, module_user} <-
           Modules.module_user(module, user) do
      assignments =
        Modules.assignments(module, user, module_user)

      programming_languages =
        ProgrammingLanguages.list_programming_languages() |> Enum.map(&{&1.name, &1.id})

      {:ok,
       socket
       |> stream(:assignments, assignments)
       |> assign(:module, module)
       |> assign(:programming_languages, programming_languages)
       |> assign(:current_page, :modules)}
    else
      {:error, reason} ->
        {:ok,
         push_navigate(socket, to: ~p"/modules")
         |> put_flash(:error, reason)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"assignment_id" => assignment_id}) do
    module_id = socket.assigns.module.id

    case Assignments.get_assignment(assignment_id, module_id) do
      {:ok, assignment} ->
        socket
        |> assign(:page_title, "Edit Assignment")
        |> assign(:assignment, assignment)

      {:error, reason} ->
        socket
        |> put_flash(:error, reason)
        |> redirect(to: ~p"/modules/#{module_id}/assignments")
    end
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
    module_id = socket.assigns.module.id

    with {:ok, assignment} <- Assignments.get_assignment(id, module_id),
         {:ok, _} <- Assignments.delete_assignment(assignment) do
      {:noreply,
       stream_delete(socket, :assignments, assignment)
       |> put_flash(:info, "Assignment deleted successfully")}
    else
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end
end
