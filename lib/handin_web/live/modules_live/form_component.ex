defmodule HandinWeb.ModulesLive.FormComponent do
  use HandinWeb, :live_component
  alias Handin.Modules

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between items-center pb-4 mb-4 rounded-t border-b sm:mb-5 dark:border-gray-600">
        <.header>
          <%= @title %>
          <:subtitle>Use this form to manage module records in your database.</:subtitle>
        </.header>
      </div>
      <.simple_form
        for={@form}
        id="module-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="grid gap-4 mb-4 sm:grid-cols-1">
          <.input field={@form[:name]} label="Name" type="text" />
          <.input field={@form[:code]} label="Code" type="text" />
        </div>
        <:actions>
          <.button
            class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
            phx-disable-with="Saving..."
          >
            <svg
              class="mr-1 -ml-1 w-6 h-6"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fill-rule="evenodd"
                d="M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 11-2 0v-3H6a1 1 0 110-2h3V6a1 1 0 011-1z"
                clip-rule="evenodd"
              >
              </path>
            </svg>
            Save module
          </.button>
          <.link
            patch={@patch}
            class="text-red-600 inline-flex items-center hover:text-white border border-red-600 hover:bg-red-600 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-red-500 dark:text-red-500 dark:hover:text-white dark:hover:bg-red-600 dark:focus:ring-red-900"
          >
            Cancel
          </.link>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{modulee: module} = assigns, socket) do
    changeset = Modules.change_module(module)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"module" => module_params}, socket) do
    changeset =
      socket.assigns.modulee
      |> Modules.change_module(module_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"module" => module_params}, socket) do
    save_module(socket, socket.assigns.action, module_params, socket.assigns.current_user.id)
  end

  defp save_module(socket, :edit, module_params, _user_id) do
    case Modules.update_module(socket.assigns.modulee, module_params) do
      {:ok, module} ->
        notify_parent({:saved, module})

        {:noreply,
         socket
         |> put_flash(:info, "module updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_module(socket, :new, module_params, user_id) do
    case Modules.create_module(module_params, user_id) do
      {:ok, module} ->
        notify_parent({:saved, module})

        {:noreply,
         socket
         |> put_flash(:info, "module created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         assign_form(socket, changeset)
         |> put_flash(:error, "An error occured")}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
