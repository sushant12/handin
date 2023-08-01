defmodule HandinWeb.MembersLive.Index do
  use HandinWeb, :live_view
  alias Handin.Modules

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    members = Modules.get_students(id)

    {:ok, stream(socket, :members, members) |> assign(:module_id, id)}
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
end
