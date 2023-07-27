defmodule HandinWeb.ModulesLive.Show do
  alias Handin.Modules
  use HandinWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    user = socket.assigns.current_user |> Handin.Repo.preload(:modules)
    module = user.modules |> Enum.find(&(&1.id == id))

    if module do
      {:noreply, assign(socket, :module, module)}
    else
      {:noreply, push_navigate(socket, to: "/modules/")}
    end
  end
end
