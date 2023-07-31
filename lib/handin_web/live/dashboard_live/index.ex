defmodule HandinWeb.DashboardLive.Index do
  use HandinWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :dashboard)}
  end
end
