defmodule HandinWeb.ModulesLive.MembersComponent do
  use HandinWeb, :live_component
  alias Handin.Accounts.User
  alias Handin.{Accounts, Modules}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between items-center pb-4 mb-4 rounded-t border-b sm:mb-5 dark:border-gray-600">
        <.header class="text-lg font-semibold text-gray-900 dark:text-white">
          Add Member
        </.header>
      </div>
      <.simple_form
        for={@form}
        id="member-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="grid gap-4 mb-4 sm:grid-cols-1">
          <div>
            <label for="roles" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
              Role
            </label>
            <.input
              field={@form[:roles]}
              type="select"
              prompt="Select role"
              options={[
                Lecturer: :lecturer,
                "Teaching Assistant": :teaching_assistant,
                Student: :student
              ]}
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
              required
            />
          </div>
          <div>
            <label for="email" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
              Email
            </label>
            <.input
              field={@form[:email]}
              type="text"
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
            />
          </div>
          OR <%!-- WIP CSV upload --%>
          <label for="email" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
            CSV input
          </label>
          <.input
            field={@form[:csv]}
            type="file"
            class="bg-gray-50 pl-7 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
          />
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
            Add member
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = User.email_changeset(%User{}, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => %{"email" => email, "roles" => role}}, socket) do
    changeset =
      %User{}
      |> User.email_changeset(%{email: email})
      |> Ecto.Changeset.change(roles: [Accounts.get_role_by_name(role)])
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"user" => %{"email" => email, "roles" => role}}, socket) do
    case user = Accounts.get_user_by_email(email) do
      %User{} ->
        role = Accounts.get_role_by_name(role)

        %{user_id: user.id, role_id: role.id}
        |> Accounts.add_user_role()

        %{user_id: user.id, module_id: socket.assigns.modulee.id}
        |> Modules.register_user_into_module()

      _ ->
        Modules.add_module_invitation(email, role, socket.assigns.modulee)
    end

    {:noreply, socket |> put_flash(:info, "User added successfully")}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
