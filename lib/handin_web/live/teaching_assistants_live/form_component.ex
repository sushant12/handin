defmodule HandinWeb.TeachingAssistantsLive.FormComponent do
  use HandinWeb, :live_component
  alias Handin.Modules
  alias Handin.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between items-center pb-4 mb-4 rounded-t border-b sm:mb-5 dark:border-gray-600">
        <.header>
          {@title}
        </.header>
      </div>
      <.simple_form for={@form} id="teaching-assistant-form" phx-target={@myself} phx-submit="save">
        <div class="grid gap-4 mb-4 sm:grid-cols-1">
          <.input field={@form[:email]} label="Email" type="text" />
        </div>

        <:actions>
          <.button
            class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
            phx-disable-with="Saving..."
          >
            Save
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
  def update(assigns, socket) do
    user_changeset = User.module_user_changeset(%User{}, %{})
    {:ok, socket |> assign(assigns) |> assign_form(user_changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => %{"email" => email}}, socket) do
    module_id = socket.assigns.module_id

    case Modules.save_teaching_assistant(email, module_id) do
      {:ok, teaching_assistant} ->
        notify_parent({:saved, teaching_assistant})

        {:noreply,
         socket
         |> put_flash(:info, "Teaching assistant added successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
