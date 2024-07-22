defmodule HandinWeb.ArchivedModulesLive.Index do
  use HandinWeb, :live_view
  alias Handin.Modules

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> load_modules()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp load_modules(socket) do
    modules = Modules.list_module(socket.assigns.current_user, :archived)
    stream(socket, :modules, modules, reset: true)
  end

  defp apply_action(socket, :index, _) do
    socket
    |> assign(:page_title, "Archived Modules ")
    |> assign(:current_page, :archived_modules)
  end

  defp apply_action(socket, :unarchive, %{"id" => id}) do
    module = Modules.get_module!(id)

    socket
    |> assign(:page_title, "UnArchive Module #{module.name}")
    |> assign(:module, module)
  end

  @impl true
  def handle_info(
        {HandinWeb.ArchivedModulesLive.ConfirmationComponent, {:unarchived, module}},
        socket
      ) do
    {:noreply, stream_delete(socket, :modules, module)}
  end
end
