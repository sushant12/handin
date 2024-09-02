defmodule HandinWeb.ModulesLive.Index do
  use HandinWeb, :live_view
  alias Handin.Modules
  alias Handin.Modules.{Module}

  @impl true
  def mount(_params, _session, socket) do
    modules = Modules.list_module(socket.assigns.current_user)
    {:ok, assign(socket, :current_page, :modules) |> stream(:modules, modules)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    with {:ok, module} <- Modules.get_module(id),
         {:ok, _module_user} <- Modules.module_user(module, socket.assigns.current_user) do
      socket
      |> assign(:page_title, "Edit Module #{module.name}")
      |> assign(:module, module)
    else
      {:error, reason} ->
        socket
        |> put_flash(:error, reason)
        |> redirect(to: ~p"/modules")
    end
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Module")
    |> assign(:module, %Module{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Modules")
    |> assign(:module, nil)
  end

  defp apply_action(socket, :clone, %{"id" => id}) do
    with {:ok, module} <- Modules.get_module(id),
         {:ok, _module_user} <- Modules.module_user(module, socket.assigns.current_user) do
      socket
      |> assign(:page_title, "Clone Module")
      |> assign(:module, module)
    else
      {:error, msg} ->
        socket
        |> put_flash(:error, msg)
        |> redirect(to: ~p"/modules")
    end
  end

  defp apply_action(socket, :archive, %{"id" => id}) do
    with {:ok, module} <- Modules.get_module(id),
         {:ok, _module_user} <- Modules.module_user(module, socket.assigns.current_user) do
      socket
      |> assign(:page_title, "Archive Module")
      |> assign(:module, module)
    else
      {:error, msg} ->
        socket
        |> put_flash(:error, msg)
        |> redirect(to: ~p"/modules")
    end
  end

  @impl true
  def handle_info({HandinWeb.ModulesLive.FormComponent, {:saved, module}}, socket) do
    {:noreply, stream_insert(socket, :modules, module)}
  end

  def handle_info({HandinWeb.ModulesLive.ConfirmationComponent, {:cloned, module}}, socket) do
    {:noreply, stream_insert(socket, :modules, module)}
  end

  def handle_info({HandinWeb.ModulesLive.ConfirmationComponent, {:archived, module}}, socket) do
    {:noreply, stream_delete(socket, :modules, module)}
  end
end
