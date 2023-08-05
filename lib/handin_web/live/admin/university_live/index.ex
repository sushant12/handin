defmodule HandinWeb.Admin.UniversityLive.Index do
  use HandinWeb, :live_view

  alias Handin.Universities
  alias Handin.Universities.University

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(socket, :universities, Universities.list_universities())
     |> assign(:current_page, :universities)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit University")
    |> assign(:university, Universities.get_university!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New University")
    |> assign(:university, %University{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Universities")
    |> assign(:university, nil)
  end

  @impl true
  def handle_info({HandinWeb.UniversityLive.FormComponent, {:saved, university}}, socket) do
    {:noreply, stream_insert(socket, :universities, university)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    university = Universities.get_university!(id)
    {:ok, _} = Universities.delete_university(university)

    {:noreply,
     stream_delete(socket, :universities, university)
     |> put_flash(:info, "University deleted successfully")}
  end
end
