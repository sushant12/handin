defmodule HandinWeb.StudentsLive.FormComponent do
  use HandinWeb, :live_component
  alias Handin.Modules
  alias Handin.Modules.AddUserToModuleParams
  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between items-center pb-4 mb-4 rounded-t border-b sm:mb-5 dark:border-gray-600">
        <.header>
          <%= @title %>
        </.header>
      </div>
      <.simple_form for={@form} id="student-form" phx-target={@myself} phx-submit="save">
        <div class="grid gap-4 mb-4 sm:grid-cols-1">
          <.input field={@form[:first_name]} label="First Name" type="text" />
        </div>
        <div class="grid gap-4 mb-4 sm:grid-cols-1">
          <.input field={@form[:last_name]} label="Last Name" type="text" />
        </div>
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
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    {:ok, module} = Modules.get_module(socket.assigns.module_id)
    user_params = Enum.into(user_params, %{}, fn {k, v} -> {String.to_existing_atom(k), v} end)

    params =
      %AddUserToModuleParams{
        users: [user_params],
        module: module
      }

    case Modules.add_users_to_module(params) do
      {:ok, %{users: users}} ->
        notify_parent({:saved, users})

        socket =
          socket
          |> put_flash(:info, "User added to module successfully")
          |> push_navigate(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}

      {:error, failed_operation, _failed_value, _changes_so_far} ->
        socket =
          socket
          |> put_flash(:error, "Failed to add user: #{inspect(failed_operation)}")
          |> assign(form: to_form(user_params, as: :user))

        {:noreply, socket}
    end
  end

  defp assign_form(socket, changeset \\ %{}, opts \\ []) do
    assign(socket, :form, to_form(changeset, opts ++ [as: "user"]))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
