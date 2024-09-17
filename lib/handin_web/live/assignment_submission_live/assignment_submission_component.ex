defmodule HandinWeb.AssignmentSubmissionsLive.AssignmentUploadComponent do
  use HandinWeb, :live_component

  alias Handin.Assignments

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header><%= @title %></.header>
      <.simple_form
        for={@form}
        id="assignment_submission-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div>
          <.live_file_input
            upload={@uploads.assignment_submission_file}
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
          />
          <%= for entry <- @uploads.assignment_submission_file.entries do %>
            <article class="upload-entry">
              <figure class="flex">
                <figcaption><%= entry.client_name %></figcaption>&nbsp;
              </figure>
              <div class="w-full bg-gray-200 rounded-full dark:bg-gray-700">
                <div
                  class="bg-blue-600 text-xs font-medium text-blue-100 text-center p-0.5 leading-none rounded-full"
                  style={"width: #{entry.progress}%"}
                >
                  <%= entry.progress %>%
                </div>
              </div>
              <.error
                :for={err <- upload_errors(@uploads.assignment_submission_file, entry)}
                class="!mt-0"
              >
                <%= error_to_string(err) %>
              </.error>
            </article>
          <% end %>
          <.error :for={err <- upload_errors(@uploads.assignment_submission_file)}>
            <%= error_to_string(err) %>
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
  def update(%{assignment: assignment} = assigns, socket) do
    changeset = Assignments.change_assignment(assignment)
    two_hundred_mb = 209_715_200_000

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:assignment_submission_file,
       accept: :any,
       max_entries: 20,
       max_file_size: two_hundred_mb
     )}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    save_assignment_submission(socket)
  end

  defp save_assignment_submission(socket) do
    case consume_uploaded_entries(socket, :assignment_submission_file, fn meta, entry ->
           handle_file_upload(socket, meta, entry)
         end) do
      [] ->
        {:noreply,
         socket
         |> put_flash(:error, "No files were uploaded")
         |> push_patch(to: socket.assigns.patch)}

      _files ->
        notify_parent({:saved, socket.assigns.assignment})

        {:noreply,
         socket
         |> put_flash(:info, "Files added successfully")
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp handle_file_upload(socket, meta, entry) do
    Handin.Repo.transaction(fn ->
      assignment_submission_file =
        Assignments.save_assignment_submission_file!(%{
          "assignment_submission_id" => socket.assigns.assignment_submission.id
        })

      Assignments.upload_assignment_submission_file(assignment_submission_file, %{
        file: %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: meta.path
        }
      })
    end)
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:too_many_files), do: "You have selected too many files"

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
