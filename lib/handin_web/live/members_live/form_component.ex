defmodule HandinWeb.MembersLive.FormComponent do
  use HandinWeb, :live_component
  alias NimbleCSV.RFC4180, as: CSV
  alias Handin.Modules
  alias Handin.Modules.AddUserToModuleParams
  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:csv_file_input, accept: ~w(.csv), max_entries: 1, max_file_size: 1_500_000)}
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
      <.simple_form
        for={@form}
        id="member-form"
        phx-target={@myself}
        phx-submit="save"
        phx-change="validate"
      >
        <div class="grid gap-4 mb-4 sm:grid-cols-1">
          <.input field={@form[:email]} label="Email" type="text" />
        </div>
        <div class="inline-flex items-center justify-center w-full">
          <hr class="w-64 h-px my-1 bg-gray-200 border-0 dark:bg-gray-700" />
          <span class="absolute px-3 font-medium text-gray-900 -translate-x-1/2 bg-white left-1/2 dark:text-white dark:bg-gray-900">
            or
          </span>
        </div>
        <div class="grid gap-4 mb-4 sm:grid-cols-1">
          <.label>Upload file</.label>
          <.live_file_input
            upload={@uploads.csv_file_input}
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
          />
          <div class="mt-1 text-sm text-gray-500 dark:text-gray-300" id="user_avatar_help">
            Upload a CSV file
          </div>
          <.error :if={@form[:csv_file_input].errors != []}>
            <%= @form[:csv_file_input].errors %>
          </.error>
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
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    email = user_params["email"]
    csv_emails = process_csv_upload(socket)

    emails = [email | csv_emails] |> Enum.reject(&is_nil/1) |> Enum.uniq()
    module = Modules.get_module!(socket.assigns.module_id)

    params = %AddUserToModuleParams{
      emails: emails,
      university_id: socket.assigns.current_user.university.id,
      module: module
    }

    case Modules.add_users_to_module(params) do
      {:ok, %{users: users}} ->
        notify_parent({:saved, users})

        socket =
          socket
          |> put_flash(:info, "Users added to module successfully")
          |> push_navigate(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, failed_operation, _failed_value, _changes_so_far} ->
        socket =
          socket
          |> put_flash(:error, "Failed to add users: #{inspect(failed_operation)}")
          |> assign(form: to_form(%{email: email}, as: :user))

        {:noreply, socket}
    end
  end

  defp process_csv_upload(socket) do
    socket.assigns.uploads.csv_file_input.entries
    |> Enum.flat_map(fn entry ->
      consume_uploaded_entry(socket, entry, fn %{path: path} ->
        File.read!(path)
        |> CSV.parse_string()
        |> Enum.map(fn
          [email] -> email
          _ -> nil
        end)
      end)
    end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  defp assign_form(socket, changeset \\ %{}, opts \\ []) do
    assign(socket, :form, to_form(changeset, opts ++ [as: "user"]))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
