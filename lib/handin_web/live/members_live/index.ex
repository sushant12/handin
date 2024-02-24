defmodule HandinWeb.MembersLive.Index do
  use HandinWeb, :live_view
  alias Handin.{Modules, Accounts}
  alias Handin.Accounts.User

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    members = Modules.get_students(id)
    module = Modules.get_module!(id)

    pending_users =
      Modules.get_pending_students(id)

    members = members ++ pending_users |> Enum.with_index(1) |> Enum.map(fn {u, i} -> Map.put(u, :index, i) end)

    {:ok,
     stream(socket, :members, members )
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
  def handle_info({HandinWeb.MembersLive.FormComponent, {:saved, member}}, socket) do
    {:noreply, stream_insert(socket, :members, member)}
  end

  def handle_info({HandinWeb.MembersLive.FormComponent, {:invited, invitation}}, socket) do
    {:noreply, stream_insert(socket, :members, %User{id: invitation.id, email: invitation.email})}
  end

  @impl true
  def handle_event("delete", %{"id" => id, "status" => "confirmed"}, socket) do
    member = Accounts.get_user!(id)
    Modules.remove_user_from_module(id, socket.assigns.module.id)

    {:noreply,
     stream_delete(socket, :members, member) |> put_flash(:info, "Member deleted successfully")}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, invitation} = Modules.delete_modules_invitations(id)

    {:noreply,
     stream_delete(socket, :members, invitation)
     |> put_flash(:info, "Member deleted successfully")}
  end
end
