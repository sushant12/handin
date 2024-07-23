defmodule HandinWeb.StudentsLive.FormComponent do
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
        </.header>
      </div>
      <.simple_form
        for={@form}
        id="student-form"
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
  def handle_event(
        "save",
        %{"modules_invitations" => modules_invitations_params},
        socket
      ) do
    if socket.assigns.uploads.csv_file_input.entries != [] do
      emails =
        consume_uploaded_entries(socket, :csv_file_input, fn %{path: path}, _entry ->
          rows =
            path
            |> File.read!()
            |> CSVParser.parse_string()

          {:ok, rows}
        end)
        |> List.flatten()
        |> Enum.filter(&(String.trim(&1) != ""))

      save_modules_invitations(socket, socket.assigns.action, %{"emails" => emails})
    else
      save_modules_invitations(
        socket,
        socket.assigns.action,
        modules_invitations_params
      )
    end
  end

  defp save_modules_invitations(socket, :new, %{"email" => email} = params) do
    with true <- Accounts.valid_email?(email, socket.assigns.current_user.university_id),
         %User{} = user <- Accounts.get_user_by_email(email),
         {:ok, %ModulesUsers{}} <-
           Modules.add_student(%{
             user_id: user.id,
             module_id: socket.assigns.module_id
           }) do
      notify_parent({:saved, user})

      {:noreply,
       socket
       |> put_flash(:info, "Student added successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Student already added")
         |> push_patch(to: socket.assigns.patch)}

      false ->
        {:noreply, socket |> assign_form(params, errors: [email: {"invalid email", []}])}

      nil ->
        case Modules.add_modules_invitations(%{
               email: email,
               module_id: socket.assigns.module_id
             }) do
          {:ok, invitation} ->
            notify_parent({:invited, invitation})

            {:noreply,
             socket
             |> put_flash(:info, "Student added successfully")
             |> push_patch(to: socket.assigns.patch)}

          _ ->
            {:noreply,
             socket
             |> put_flash(:error, "Student already added")
             |> push_patch(to: socket.assigns.patch)}
        end
    end
  end

  defp save_modules_invitations(socket, :new, %{"emails" => emails} = params) do
    emails
    |> Enum.filter(fn email ->
      !Accounts.valid_email?(email, socket.assigns.current_user.university_id)
    end)
    |> case do
      [] ->
        Enum.each(emails, fn email ->
          case Accounts.get_user_by_email(email) do
            %User{} = user ->
              notify_parent({:saved, user})

              Modules.add_student(%{
                user_id: user.id,
                module_id: socket.assigns.module_id
              })

            nil ->
              case Modules.add_modules_invitations(%{
                     email: email,
                     module_id: socket.assigns.module_id
                   }) do
                {:ok, invitation} ->
                  notify_parent({:invited, invitation})

                _ ->
                  :ok
              end
          end
        end)

        {:noreply,
         socket
         |> put_flash(:info, "Student added successfully")
         |> push_patch(to: socket.assigns.patch)}

      emails ->
        {:noreply,
         socket
         |> assign_form(params,
           errors: [csv_file_input: "invalid emails #{Enum.join(emails, ", ")}"]
         )}
    end
  end

  defp assign_form(socket, changeset \\ %{}, opts \\ []) do
    assign(socket, :form, to_form(changeset, opts ++ [as: "modules_invitations"]))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
