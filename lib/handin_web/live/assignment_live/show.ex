defmodule HandinWeb.AssignmentLive.Show do
  use HandinWeb, :live_view

  alias Handin.Modules

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = socket.assigns.current_user

    with {:ok, module} <- Modules.get_module(id),
         {:ok, module_user} <-
           Modules.module_user(module, user) do
      {:ok,
       socket
       |> assign(current_page: :modules)
       |> assign(:module_user, module_user)
       |> assign(:module, Modules.get_module!(id))}
    else
      {:error, reason} ->
        {:ok,
         push_navigate(socket, to: ~p"/modules")
         |> put_flash(:error, reason)}
    end
  end
end
