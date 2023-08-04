defmodule HandinWeb.MembersLive.FormComponent do
  use HandinWeb, :live_component
  alias NimbleCSV.RFC4180, as: CSVParser
  alias Handin.Modules
  alias Handin.Accounts
  alias Handin.Accounts.User
  alias Handin.Modules.ModulesUsers

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:csv_file_input, accept: ~w(.csv), max_entries: 1, max_file_size: 1_500_000)}
  end

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
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
          />
          <div class="mt-1 text-sm text-gray-500 dark:text-gray-300" id="user_avatar_help">
            A profile picture is useful to confirm your are logged into your account
          </div>
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
            Save member
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
  def update(%{modules_invitations: modules_invitations} = assigns, socket) do
    changeset = Modules.change_modules_invitations(modules_invitations)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "save",
        %{"modules_invitations" => modules_invitations_params},
        socket
      ) do
    if socket.assigns.uploads.csv_file_input.entries != [] do
      uploaded_files =
        consume_uploaded_entries(socket, :csv_file_input, fn %{path: path}, _entry ->
          rows =
            path
            |> File.read!()
            |> CSVParser.parse_string()

          {:ok, rows}
        end)
        |> List.flatten()

      Enum.each(uploaded_files, fn row ->
        save_modules_invitations(socket, socket.assigns.action, %{"email" => row})
      end)

      {:noreply,
       socket
       |> put_flash(:info, "member added successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      save_modules_invitations(
        socket,
        socket.assigns.action,
        modules_invitations_params
      )
    end
  end

  defp save_modules_invitations(socket, :new, %{"email" => email}) do
    with %User{} = user <- Accounts.get_user_by_email(email),
         {:ok, %ModulesUsers{}} <-
           Modules.add_member(%{
             user_id: user.id,
             module_id: socket.assigns.module_id
           }) do
      notify_parent({:saved, user})

      {:noreply,
       socket
       |> put_flash(:info, "member added successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}

      nil ->
        Modules.add_modules_invitations(%{
          email: email,
          module_id: socket.assigns.module_id
        })

        {:noreply,
         socket
         |> put_flash(:info, "member added successfully")
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
