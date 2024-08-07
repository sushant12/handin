defmodule HandinWeb.MembersLive.Index do
  use HandinWeb, :live_view
  alias Handin.{Modules, Accounts}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    module = Modules.get_module!(id)

    students = Modules.get_students(module.id)

    {:ok,
     stream(socket, :members, students)
     |> assign(:module, module)
     |> assign(:current_tab, :members)
     |> assign(:current_page, :modules)}
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
    |> assign(:page_title, "Listing Members")
    |> assign(:members, nil)
  end

  @impl true
  def handle_info({HandinWeb.MembersLive.FormComponent, {:saved, users}}, socket) do
    {:noreply, stream_insert(socket, :members, users)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Accounts.get_user!(id)
    {:ok, module_user} = Modules.remove_user_from_module(id, socket.assigns.module.id)

    {:noreply,
     stream_delete(socket, :members, module_user.user)
     |> put_flash(:info, "Member deleted successfully")}
  end
end
