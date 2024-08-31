defmodule HandinWeb.TeachingAssistantsLive.Index do
  use HandinWeb, :live_view
  alias Handin.{Modules}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      with {:ok, module} <- Modules.get_module(id),
           {:ok, _module_user} <- Modules.module_user(module, socket.assigns.current_user) do
        teaching_assistants = Modules.get_teaching_assistants(module.id)

        {:ok,
         stream(socket, :teaching_assistants, teaching_assistants)
         |> assign(:module, module)
         |> assign(:current_tab, :teaching_assistants)
         |> assign(:current_page, :modules)}
      else
        {:error, reason} ->
          {:ok,
           push_navigate(socket, to: ~p"/modules")
           |> put_flash(:error, reason)}
      end
    else
      {:ok,
       socket
       |> assign(:module, nil)
       |> stream(:teaching_assistants, [])
       |> assign(:current_tab, :teaching_assistants)
       |> assign(:current_page, :modules)}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case Modules.remove_teaching_assistant(id, socket.assigns.module.id) do
      {:ok, teaching_assistant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Teaching assistant removed successfully")
         |> stream_delete(:teaching_assistants, teaching_assistant)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to remove teaching assistant: #{reason}")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New TA")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing TAs")
  end

  @impl true
  def handle_info(
        {HandinWeb.TeachingAssistantsLive.FormComponent, {:saved, teaching_assistant}},
        socket
      ) do
    {:noreply, stream_insert(socket, :teaching_assistants, teaching_assistant)}
  end
end
