defmodule HandinWeb.AssignmentLive.AssignmentTestComponent do
  use HandinWeb, :live_component

  alias Handin.AssignmentTests

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="assignment_test-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:marks]} type="number" label="Marks" />
        <.input field={@form[:command]} type="text" label="Command" />

        <.label>Add test support file</.label>
        <.live_file_input
          upload={@uploads.test_support_file}
          class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
        />
        <%= for entry <- @uploads.test_support_file.entries do %>
          <article class="upload-entry">
            <figure class="flex">
              <svg
                width="1.25rem"
                height="1.25rem"
                viewBox="0 0 24 24"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                <g id="SVGRepo_iconCarrier">
                  <path
                    d="M9 17H15M9 13H15M9 9H10M13 3H8.2C7.0799 3 6.51984 3 6.09202 3.21799C5.71569 3.40973 5.40973 3.71569 5.21799 4.09202C5 4.51984 5 5.0799 5 6.2V17.8C5 18.9201 5 19.4802 5.21799 19.908C5.40973 20.2843 5.71569 20.5903 6.09202 20.782C6.51984 21 7.0799 21 8.2 21H15.8C16.9201 21 17.4802 21 17.908 20.782C18.2843 20.5903 18.5903 20.2843 18.782 19.908C19 19.4802 19 18.9201 19 17.8V9M13 3L19 9M13 3V7.4C13 7.96005 13 8.24008 13.109 8.45399C13.2049 8.64215 13.3578 8.79513 13.546 8.89101C13.7599 9 14.0399 9 14.6 9H19"
                    stroke="#707070"
                    stroke-width="2"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  >
                  </path>
                </g>
              </svg>
              <figcaption><%= entry.client_name %></figcaption>
            </figure>
          </article>
        <% end %>
        <%= for err <- upload_errors(@uploads.test_support_file) do %>
          <p class="alert alert-danger"><%= error_to_string(err) %></p>
        <% end %>
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
  def update(%{assignment_test: assignment_test} = assigns, socket) do
    changeset = AssignmentTests.change_assignment_test(assignment_test)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:test_support_file, accept: :any, max_entries: 5, max_file_size: 1_500_000)}
  end

  @impl true
  def handle_event("validate", %{"assignment_test" => assignment_test_params}, socket) do
    changeset =
      socket.assigns.assignment_test
      |> AssignmentTests.change_assignment_test(assignment_test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"assignment_test" => assignment_test_params}, socket) do
    save_assignment_test(
      socket,
      socket.assigns.action,
      Map.put(assignment_test_params, "assignment_id", socket.assigns.assignment_id)
    )
  end

  defp save_assignment_test(socket, :edit_assignment_test, assignment_test_params) do
    case AssignmentTests.update_assignment_test(
           socket.assigns.assignment_test,
           assignment_test_params
         ) do
      {:ok, assignment_test} ->
        consume_entries(socket, assignment_test)
        notify_parent({:saved, assignment_test})

        {:noreply,
         socket
         |> put_flash(:info, "Assignment test updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_assignment_test(socket, :add_assignment_test, assignment_test_params) do
    case AssignmentTests.create_assignment_test(assignment_test_params) do
      {:ok, assignment_test} ->
        consume_entries(socket, assignment_test)

        notify_parent({:saved, assignment_test})

        {:noreply,
         socket
         |> put_flash(:info, "Assignment test created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp consume_entries(socket, assignment_test) do
    consume_uploaded_entries(socket, :test_support_file, fn meta, entry ->
      AssignmentTests.upload_test_support_file(%{
        "file" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: meta.path
        },
        "assignment_test_id" => assignment_test.id
      })
    end)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:too_many_files), do: "You have selected too many files"
end
