defmodule HandinWeb.AssignmentTestLive.TestSupportFileComponent do
  use HandinWeb, :live_component

  alias Handin.AssignmentTests

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:test_support_file,
       accept: :any,
       max_entries: 1,
       max_file_size: 1_500_000
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage test support files records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="test_support_file-form"
        phx-target={@myself}
        phx-submit="save"
        phx-change="validate"
      >
        <.label>Upload test support file</.label>
        <.live_file_input
          upload={@uploads.test_support_file}
          class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
        />
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
            </svg>Save test support file
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
  def update(%{test_support_file: test_support_file} = assigns, socket) do
    changeset = AssignmentTests.change_test_support_file(test_support_file)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :test_support_file, fn meta, entry ->
        {:ok, test_support_file} =
          AssignmentTests.create_test_support_file(%{
            "file" => %Plug.Upload{
              content_type: entry.client_type,
              filename: entry.client_name,
              path: meta.path
            },
            "assignment_test_id" => socket.assigns.assignment_test.id
          })

        Handin.TestSupportFileUploader.url({test_support_file.file, test_support_file}, :original)
        {:ok, test_support_file}
      end)

    {:noreply,
     update(socket, :uploaded_files, &(&1 ++ uploaded_files))
     |> put_flash(:info, "Test support file created successfully")
     |> push_patch(to: socket.assigns.patch)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
