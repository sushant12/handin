defmodule HandinWeb.StudentsLive.Index do
  use HandinWeb, :live_view
  alias Handin.{Modules, Accounts}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = socket.assigns.current_user

    with {:ok, module} <- Modules.get_module(id),
         {:ok, module_user} <- Modules.module_user(module, user) do
      students = Modules.get_students(module.id)

      {:ok,
       stream(socket, :students, students)
       |> assign(:module, module)
       |> assign(:current_tab, :students)
       |> assign(:module_user, module_user)
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

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Member")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Students")
    |> assign(:students, nil)
  end

  @impl true
  def handle_info({HandinWeb.StudentsLive.FormComponent, {:saved, users}}, socket) do
    {:noreply, stream_insert(socket, :students, users)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Accounts.get_user!(id)
    {:ok, module_user} = Modules.remove_user_from_module(id, socket.assigns.module.id)

    {:noreply,
     stream_delete(socket, :students, module_user.user)
     |> put_flash(:info, "Student deleted successfully")}
  end
end
