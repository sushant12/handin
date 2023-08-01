defmodule HandinWeb.MembersLive.FormComponent do
  alias Inspect.Handin.Accounts
  use HandinWeb, :live_component
  alias Handin.Modules
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between items-center pb-4 mb-4 rounded-t border-b sm:mb-5 dark:border-gray-600">
        <.header >
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
          <.input
            field={@form[:role]}
            label="Role"
            multiple={false}
            options={["Lecturer", "Teaching Assistant", "Student"]}
            type="select"
          />
          <.input field={@form[:email]} label="Email" type="text" />
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
            patch={~p"/modules/#{@module_id}/members/"}
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
  def handle_event("validate", %{"modules_invitations" => modules_invitations_params}, socket) do
    changeset =
      socket.assigns.modules_invitations
      |> Modules.change_modules_invitations(modules_invitations_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"modules_invitations" => modules_invitations_params}, socket) do
    save_modules_invitations(
      socket,
      socket.assigns.action,
      modules_invitations_params,
      socket.assigns.current_user.id
    )
  end

  defp save_modules_invitations(socket, :new, modules_invitations_params, user_id) do
    with {:ok, user} <- Accounts.get_user_by_email(modules_invitations_params.email),
         {:ok, module} <-
           Modules.add_member(%{
             user_id: user.id,
             role_id: modules_invitations_params.role_id,
             module_id: socket.assigns.module_id
           }) do
      notify_parent({:saved, module})
    end

    # find the user via the email address
    # if the user is found, add the user to the module
    # if not found, add the record to the module_invitation table

    # case Modules.create_module(module_params, user_id) do
    #   {:ok, module} ->
    #     notify_parent({:saved, module})

    #     {:noreply,
    #      socket
    #      |> put_flash(:info, "module created successfully")
    #      |> push_patch(to: socket.assigns.patch)}

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     {:noreply, assign_form(socket, changeset)}
    # end
    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
