defmodule HandinWeb.ArchivedModulesLive.ConfirmationComponent do
  use HandinWeb, :live_component

  alias Handin.Modules
  alias Handin.Modules.{Module}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4 md:p-5 text-center">
      <svg
        class="mx-auto mb-4 text-gray-400 w-12 h-12 dark:text-gray-200"
        aria-hidden="true"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 20 20"
      >
        <path
          stroke="currentColor"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M10 11V6m0 8h.01M19 10a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
        />
      </svg>
      <h3 class="mb-5 text-lg font-normal text-gray-500 dark:text-gray-400">{@message}</h3>
      <.button
        class="text-white bg-red-600 hover:bg-red-800 focus:ring-4 focus:outline-none focus:ring-red-300 dark:focus:ring-red-800 font-medium rounded-lg text-sm inline-flex items-center px-5 py-2.5 text-center"
        phx-click={@confirm_event}
        phx-value-id={@id}
        phx-target={@myself}
        phx-disable-with="Saving..."
      >
        Yes, I'm sure
      </.button>
      <.link
        patch={@patch}
        type="button"
        class="py-2.5 px-5 ms-3 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-100 dark:focus:ring-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700"
      >
        No, cancel
      </.link>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("unarchive", %{"id" => id}, socket) do
    with %Module{} = module <- Modules.get_module!(id),
         {:ok, module} <- Modules.unarchive_module(module) do
      notify_parent({:unarchived, module})

      {:noreply,
       socket
       |> put_flash(:info, "Module unarchived successfully.")
       |> push_patch(to: socket.assigns.patch)}
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Failed to unarchive module")}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
