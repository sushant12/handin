defmodule HandinWeb.Admin.UniversityLive.FormComponent do
  use HandinWeb, :live_component

  alias Handin.Universities

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between items-center pb-4 mb-4 rounded-t border-b sm:mb-5 dark:border-gray-600">
        <.header>
          <%= @title %>
          <:subtitle>Use this form to manage university records in your database.</:subtitle>
        </.header>
      </div>

      <.simple_form
        for={@form}
        id="university-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="grid gap-4 mb-4 sm:grid-cols-1">
          <.input field={@form[:name]} label="Name" type="text" />
          <.input field={@form[:student_email_regex]} label="Student Email Regex" type="text" />
          <.input
            field={@form[:timezone]}
            label="Timezone"
            type="select"
            options={Tzdata.zone_lists_grouped()}
          />
        </div>
        <:actions>
          <.button
            phx-disable-with="Saving..."
            class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
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
            </svg>Save University
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
  def update(%{university: university} = assigns, socket) do
    changeset = Universities.change_university(university)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"university" => university_params}, socket) do
    changeset =
      socket.assigns.university
      |> Universities.change_university(university_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"university" => university_params}, socket) do
    save_university(socket, socket.assigns.action, university_params)
  end

  defp save_university(socket, :edit, university_params) do
    IO.inspect(university_params)

    case Universities.update_university(socket.assigns.university, university_params) do
      {:ok, university} ->
        notify_parent({:saved, university})

        {:noreply,
         socket
         |> put_flash(:info, "University updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_university(socket, :new, university_params) do
    case Universities.create_university(university_params) do
      {:ok, university} ->
        notify_parent({:saved, university})

        {:noreply,
         socket
         |> put_flash(:info, "University created successfully")
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
