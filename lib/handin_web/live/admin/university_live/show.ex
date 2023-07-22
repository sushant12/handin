defmodule HandinWeb.Admin.UniversityLive.Show do
  use HandinWeb, :live_view

  alias Handin.Universities

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:university, Universities.get_university!(id))}
  end

  defp page_title(:show), do: "Show University"
  defp page_title(:edit), do: "Edit University"
end
