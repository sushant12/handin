defmodule HandinWeb.Admin.ProgrammingLanguageLive.FormComponent do
  use HandinWeb, :live_component

  alias Handin.ProgrammingLanguages

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage programming_language records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="programming_language-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:docker_file_url]} type="text" label="Docker file url" />
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
            </svg>Save Programming language
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
  def update(%{programming_language: programming_language} = assigns, socket) do
    changeset = ProgrammingLanguages.change_programming_language(programming_language)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"programming_language" => programming_language_params}, socket) do
    changeset =
      socket.assigns.programming_language
      |> ProgrammingLanguages.change_programming_language(programming_language_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"programming_language" => programming_language_params}, socket) do
    save_programming_language(socket, socket.assigns.action, programming_language_params)
  end

  defp save_programming_language(socket, :edit, programming_language_params) do
    case ProgrammingLanguages.update_programming_language(
           socket.assigns.programming_language,
           programming_language_params
         ) do
      {:ok, programming_language} ->
        notify_parent({:saved, programming_language})

        {:noreply,
         socket
         |> put_flash(:info, "Programming language updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_programming_language(socket, :new, programming_language_params) do
    case ProgrammingLanguages.create_programming_language(programming_language_params) do
      {:ok, programming_language} ->
        notify_parent({:saved, programming_language})

        {:noreply,
         socket
         |> put_flash(:info, "Programming language created successfully")
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
