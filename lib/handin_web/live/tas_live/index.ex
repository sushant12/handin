defmodule HandinWeb.TAsLive.Index do
  use HandinWeb, :live_view
  alias Handin.{Modules, Accounts}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    module = Modules.get_module!(id)

    members = get_all_members(id) |> put_indexes()

    {:ok,
     stream(socket, :members, members)
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
  def handle_info({HandinWeb.MembersLive.FormComponent, {:saved, _member}}, socket) do
    members = get_all_members(socket.assigns.module.id) |> put_indexes()
    {:noreply, stream(socket, :members, members)}
  end

  def handle_info({HandinWeb.MembersLive.FormComponent, {:invited, _invitation}}, socket) do
    members = get_all_members(socket.assigns.module.id) |> put_indexes()
    {:noreply, stream(socket, :members, members)}
  end

  @impl true
  def handle_event("delete", %{"id" => id, "status" => "confirmed"}, socket) do
    Accounts.get_user!(id)
    Modules.remove_user_from_module(id, socket.assigns.module.id)

    members = get_all_members(socket.assigns.module.id) |> put_indexes()

    {:noreply,
     stream(socket, :members, members) |> put_flash(:info, "Member deleted successfully")}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    Modules.delete_modules_invitations(id)

    members = get_all_members(socket.assigns.module.id) |> put_indexes()

    {:noreply,
     stream(socket, :members, members)
     |> put_flash(:info, "Member deleted successfully")}
  end

  defp put_indexes(items), do: Enum.with_index(items, &Map.put(&1, :index, &2 + 1))

  defp get_all_members(module_id),
    do: Modules.get_students(module_id) ++ Modules.get_pending_students(module_id)
end
