defmodule HandinWeb.AssignmentSubmission.AssignmentUploadComponent do
  use HandinWeb, :live_component
  alias Handin.AssignmentSubmissions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="assignment_upload_form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div>
          <label>Upload Assignment Files</label>
          <.live_file_input
            upload={@uploads.assignment_submission_schema}
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
          />
          <%= for entry <- @uploads.assignment_submission_schema.entries do %>
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
          <%= for err <- upload_errors(@uploads.assignment_submission_schema) do %>
            <p class="alert alert-danger"><%= error_to_string(err) %></p>
          <% end %>
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
    changeset = AssignmentSubmissions.change_submission(assigns.assignment_submission_schema)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:assignment_submission_schema,
       accept: :any,
       max_entries: 5,
       max_file_size: 1_500_000
     )}
  end

  @impl true
  def handle_event("validate", _, socket), do: {:noreply, socket}

  def handle_event("save", _, socket) do
    assignment_submission =
      AssignmentSubmissions.create_or_update_submission(
        socket.assigns.assignment_submission_schema
      )

    consume_uploaded_entries(socket, :assignment_submission_schema, fn meta, entry ->
      Handin.Repo.transaction(fn ->
        assignment_submission_file =
          AssignmentSubmissions.save_assignment_submission_file(%{
            "assignment_submission_id" => assignment_submission.id
          })

        AssignmentSubmissions.upload_file(assignment_submission_file, %{
          "file" => %Plug.Upload{
            content_type: entry.client_type,
            filename: entry.client_name,
            path: meta.path
          }
        })
      end)
    end)

    notify_parent({:saved, assignment_submission})

    {:noreply,
     socket
     |> put_flash(:info, "Done")
     |> push_patch(to: socket.assigns.patch)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:too_many_files), do: "You have selected too many files"
end
