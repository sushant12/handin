defmodule HandinWeb.AssignmentLive.AssignmentTestComponent do
  use HandinWeb, :live_component

  alias Handin.AssignmentTests
  alias Handin.Assignments
  alias Handin.SupportFileUploader

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.input
        :if={@action == :add_assignment_test}
        name="copy_test"
        type="select"
        value={nil}
        label="Copy from test"
        options={@available_tests}
        prompt="Select test to copy"
        phx-target={@myself}
        phx-click="copy_test"
      />

      <.simple_form
        for={@form}
        id="assignment_test-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="grid grid-cols-2 gap-4">
          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:marks]} type="number" label="Marks" />
        </div>

        <div>
          <label>Add test support file</label>
          <.live_file_input
            upload={@uploads.support_file}
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
          />
          <%= for support_file <- @support_files do %>
            <article :if={support_file.file} class="upload-entry">
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
                <figcaption><%= support_file.file.file_name %></figcaption>&nbsp;
                <button
                  :if={@action == :add_assignment_test}
                  type="button"
                  phx-click="cancel-copy"
                  phx-value-support_file_id={support_file.id}
                  phx-target={@myself}
                  aria-label="cancel"
                >
                  <svg
                    width="1.25rem"
                    height="1.25rem"
                    viewBox="0 0 1024 1024"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="#ff0000"
                    stroke="#ff0000"
                  >
                    <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                    <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                    <g id="SVGRepo_iconCarrier">
                      <path
                        fill="#dd3636"
                        d="M160 256H96a32 32 0 0 1 0-64h256V95.936a32 32 0 0 1 32-32h256a32 32 0 0 1 32 32V192h256a32 32 0 1 1 0 64h-64v672a32 32 0 0 1-32 32H192a32 32 0 0 1-32-32V256zm448-64v-64H416v64h192zM224 896h576V256H224v640zm192-128a32 32 0 0 1-32-32V416a32 32 0 0 1 64 0v320a32 32 0 0 1-32 32zm192 0a32 32 0 0 1-32-32V416a32 32 0 0 1 64 0v320a32 32 0 0 1-32 32z"
                      >
                      </path>
                    </g>
                  </svg>
                </button>
              </figure>
            </article>
          <% end %>
          <%= for entry <- @uploads.support_file.entries do %>
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
                <figcaption><%= entry.client_name %></figcaption>&nbsp;
                <button
                  :if={@action == :add_assignment_test}
                  type="button"
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  phx-target={@myself}
                  aria-label="cancel"
                >
                  <svg
                    width="1.25rem"
                    height="1.25rem"
                    viewBox="0 0 1024 1024"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="#ff0000"
                    stroke="#ff0000"
                  >
                    <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                    <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                    <g id="SVGRepo_iconCarrier">
                      <path
                        fill="#dd3636"
                        d="M160 256H96a32 32 0 0 1 0-64h256V95.936a32 32 0 0 1 32-32h256a32 32 0 0 1 32 32V192h256a32 32 0 1 1 0 64h-64v672a32 32 0 0 1-32 32H192a32 32 0 0 1-32-32V256zm448-64v-64H416v64h192zM224 896h576V256H224v640zm192-128a32 32 0 0 1-32-32V416a32 32 0 0 1 64 0v320a32 32 0 0 1-32 32zm192 0a32 32 0 0 1-32-32V416a32 32 0 0 1 64 0v320a32 32 0 0 1-32 32z"
                      >
                      </path>
                    </g>
                  </svg>
                </button>
              </figure>
            </article>
          <% end %>
          <%= for err <- upload_errors(@uploads.support_file) do %>
            <p class="alert alert-danger"><%= error_to_string(err) %></p>
          <% end %>
        </div>
        <div>
          <label>Add solution file</label>
          <.live_file_input
            upload={@uploads.solution_file}
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
          />
          <%= for solution_file <- @solution_files do %>
            <article :if={solution_file.file} class="upload-entry">
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
                <figcaption><%= solution_file.file.file_name %></figcaption>&nbsp;
                <button
                  :if={@action == :add_assignment_test}
                  type="button"
                  phx-click="cancel-copy"
                  phx-value-solution_file_id={solution_file.id}
                  phx-target={@myself}
                  aria-label="cancel"
                >
                  <svg
                    width="1.25rem"
                    height="1.25rem"
                    viewBox="0 0 1024 1024"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="#ff0000"
                    stroke="#ff0000"
                  >
                    <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                    <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                    <g id="SVGRepo_iconCarrier">
                      <path
                        fill="#dd3636"
                        d="M160 256H96a32 32 0 0 1 0-64h256V95.936a32 32 0 0 1 32-32h256a32 32 0 0 1 32 32V192h256a32 32 0 1 1 0 64h-64v672a32 32 0 0 1-32 32H192a32 32 0 0 1-32-32V256zm448-64v-64H416v64h192zM224 896h576V256H224v640zm192-128a32 32 0 0 1-32-32V416a32 32 0 0 1 64 0v320a32 32 0 0 1-32 32zm192 0a32 32 0 0 1-32-32V416a32 32 0 0 1 64 0v320a32 32 0 0 1-32 32z"
                      >
                      </path>
                    </g>
                  </svg>
                </button>
              </figure>
            </article>
          <% end %>
          <%= for entry <- @uploads.solution_file.entries do %>
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
                <figcaption><%= entry.client_name %></figcaption>&nbsp;
                <button
                  :if={@action == :add_assignment_test}
                  type="button"
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  phx-target={@myself}
                  aria-label="cancel"
                >
                  <svg
                    width="1.25rem"
                    height="1.25rem"
                    viewBox="0 0 1024 1024"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="#ff0000"
                    stroke="#ff0000"
                  >
                    <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                    <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                    <g id="SVGRepo_iconCarrier">
                      <path
                        fill="#dd3636"
                        d="M160 256H96a32 32 0 0 1 0-64h256V95.936a32 32 0 0 1 32-32h256a32 32 0 0 1 32 32V192h256a32 32 0 1 1 0 64h-64v672a32 32 0 0 1-32 32H192a32 32 0 0 1-32-32V256zm448-64v-64H416v64h192zM224 896h576V256H224v640zm192-128a32 32 0 0 1-32-32V416a32 32 0 0 1 64 0v320a32 32 0 0 1-32 32zm192 0a32 32 0 0 1-32-32V416a32 32 0 0 1 64 0v320a32 32 0 0 1-32 32z"
                      >
                      </path>
                    </g>
                  </svg>
                </button>
              </figure>
            </article>
          <% end %>
          <%= for err <- upload_errors(@uploads.solution_file) do %>
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
  def update(%{assignment_test: assignment_test} = assigns, socket) do
    changeset = AssignmentTests.change_assignment_test(assignment_test)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:support_file, accept: :any, max_entries: 5, max_file_size: 1_500_000)
     |> allow_upload(:solution_file, accept: :any, max_entries: 5, max_file_size: 1_500_000)}
  end

  @impl true
  def handle_event("validate", %{"assignment_test" => assignment_test_params}, socket) do
    changeset =
      socket.assigns.assignment_test
      |> AssignmentTests.change_assignment_test(assignment_test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("copy_test", %{"value" => ""}, socket), do: {:noreply, socket}

  def handle_event("copy_test", %{"value" => id}, socket) do
    assignment_test = AssignmentTests.get_assignment_test!(id)
    assignment_test_attrs = assignment_test |> get_attrs()

    support_files = assignment_test.support_files
    solution_files = assignment_test.solution_files

    changeset =
      socket.assigns.assignment_test
      |> AssignmentTests.change_assignment_test(assignment_test_attrs)
      |> Map.put(:action, :validate)

    {:noreply,
     assign_form(socket, changeset)
     |> assign(:support_files, support_files)
     |> assign(:solution_files, solution_files)}
  end

  def handle_event("cancel-copy", %{"test_support_file_id" => test_support_file_id}, socket) do
    support_files =
      socket.assigns.support_files
      |> Enum.reject(&(&1.id == test_support_file_id))

    {:noreply,
     assign(
       socket,
       :support_files,
       support_files
     )}
  end

  def handle_event("cancel-copy", %{"solution_file_id" => solution_file_id}, socket) do
    solution_files =
      socket.assigns.solution_files
      |> Enum.reject(&(&1.id == solution_file_id))

    {:noreply,
     assign(
       socket,
       :solution_files,
       solution_files
     )}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply,
     socket |> cancel_upload(:support_file, ref) |> cancel_upload(:solution_file, ref)}
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
        # Copies test support files from a selected assignment_test
        socket.assigns.support_files
        |> Enum.map(fn support_file ->
          if support_file.file do
            file_name = support_file.file.file_name

            url =
              SupportFileUploader.url({file_name, support_file},
                signed: true
              )

            {:ok, %Finch.Response{status: 200, body: body}} =
              Finch.build(:get, url)
              |> Finch.request(Handin.Finch)

            {:ok, support_file} =
              Assignments.save_support_file(%{"assignment_test_id" => assignment_test.id})

            File.mkdir_p!("/tmp/uploads/#{support_file.id}")
            File.write!("/tmp/uploads/#{support_file.id}/#{file_name}", body)

            Assignments.upload_support_file(support_file, %{
              "file" => %Plug.Upload{
                content_type: MIME.from_path(file_name),
                filename: file_name,
                path: "/tmp/uploads/#{support_file.id}/#{file_name}"
              }
            })
          end
        end)

        # Copies solution files from a selected assignment_test
        socket.assigns.solution_files
        |> Enum.map(fn solution_file ->
          if solution_file.file do
            file_name = solution_file.file.file_name

            url =
              SupportFileUploader.url({file_name, solution_file},
                signed: true
              )

            {:ok, %Finch.Response{status: 200, body: body}} =
              Finch.build(:get, url)
              |> Finch.request(Handin.Finch)

            {:ok, solution_file} =
              Assignments.save_solution_file(%{"assignment_test_id" => assignment_test.id})

            File.mkdir_p!("/tmp/uploads/#{solution_file.id}")
            File.write!("/tmp/uploads/#{solution_file.id}/#{file_name}", body)

            Assignments.upload_solution_file(solution_file, %{
              "file" => %Plug.Upload{
                content_type: MIME.from_path(file_name),
                filename: file_name,
                path: "/tmp/uploads/#{solution_file.id}/#{file_name}"
              }
            })
          end
        end)

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
    consume_uploaded_entries(socket, :support_file, fn meta, entry ->
      Handin.Repo.transaction(fn ->
        {:ok, support_file} =
          Assignments.save_support_file(%{"assignment_test_id" => assignment_test.id})

        Assignments.upload_support_file(support_file, %{
          "file" => %Plug.Upload{
            content_type: entry.client_type,
            filename: entry.client_name,
            path: meta.path
          }
        })
      end)
    end)

    consume_uploaded_entries(socket, :solution_file, fn meta, entry ->
      Handin.Repo.transaction(fn ->
        {:ok, solution_file} =
          Assignments.save_solution_file(%{"assignment_test_id" => assignment_test.id})

        Assignments.upload_solution_file(solution_file, %{
          "file" => %Plug.Upload{
            content_type: entry.client_type,
            filename: entry.client_name,
            path: meta.path
          }
        })
      end)
    end)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:too_many_files), do: "You have selected too many files"

  defp get_attrs(assignment_test) do
    %{
      name: assignment_test.name,
      marks: assignment_test.marks,
      assignment_id: assignment_test.assignment_id
    }
  end
end
