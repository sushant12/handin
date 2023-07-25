defmodule HandinWeb.ModulesLive.Show do
  alias Handin.Modules
  use HandinWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:module, Modules.get_module!(id))}
  end
end