defmodule HandinWeb.ModulesLive.Index do
  use HandinWeb, :live_view
  alias Handin.Modules.Module
  alias Handin.Modules

  @impl true
  def mount(_params, _session, socket) do
    modules =
      socket.assigns.current_user.id
      |> Modules.list_modules_for_user()

    {:ok, stream(socket, :modules, modules) |> assign(:current_page, :modules)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Module")
    |> assign(:module, Modules.get_module!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Module")
    |> assign(:module, %Module{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Modulees")
    |> assign(:module, nil)
  end

  @impl true
  def handle_info({HandinWeb.ModulesLive.FormComponent, {:saved, module}}, socket) do
    {:noreply, stream_insert(socket, :modules, module)}
  end
end
