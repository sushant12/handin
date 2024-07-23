defmodule HandinWeb.StudentsLive.Index do
  use HandinWeb, :live_view
  alias Handin.{Modules, Accounts}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    module = Modules.get_module!(id)

    students = get_all_students(id) |> put_indexes()

    {:ok,
     stream(socket, :students, students)
     |> assign(:module, module)
     |> assign(:current_tab, :students)
     |> assign(:current_page, :modules)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Student")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Students")
    |> assign(:students, nil)
  end

  @impl true
  def handle_info({HandinWeb.StudentsLive.FormComponent, {:saved, _student}}, socket) do
    students = get_all_students(socket.assigns.module.id) |> put_indexes()
    {:noreply, stream(socket, :students, students)}
  end

  def handle_info({HandinWeb.StudentsLive.FormComponent, {:invited, _invitation}}, socket) do
    students = get_all_students(socket.assigns.module.id) |> put_indexes()
    {:noreply, stream(socket, :students, students)}
  end

  @impl true
  def handle_event("delete", %{"id" => id, "status" => "confirmed"}, socket) do
    Accounts.get_user!(id)
    Modules.remove_user_from_module(id, socket.assigns.module.id)

    students = get_all_students(socket.assigns.module.id) |> put_indexes()

    {:noreply,
     stream(socket, :students, students) |> put_flash(:info, "Student deleted successfully")}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    Modules.delete_modules_invitations(id)

    students = get_all_students(socket.assigns.module.id) |> put_indexes()

    {:noreply,
     stream(socket, :students, students)
     |> put_flash(:info, "Student deleted successfully")}
  end

  defp put_indexes(items), do: Enum.with_index(items, &Map.put(&1, :index, &2 + 1))

  defp get_all_students(module_id),
    do: Modules.get_students(module_id) ++ Modules.get_pending_students(module_id)
end
