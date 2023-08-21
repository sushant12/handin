defmodule HandinWeb.AssignmentLive.AssignmentTestComponent do
  use HandinWeb, :live_component

  alias Handin.AssignmentTests
  alias Handin.Assignments.Command

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
        <div class="grid grid-cols-2 gap-4">
          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:marks]} type="number" label="Marks" />
        </div>

        <div>
          <label>Commands</label>
          <.button type="button" phx-click="add_command_fields" phx-target={@myself}>
            <svg
              width="1.25rem"
              height="1.25rem"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
              stroke="#2ac666"
            >
              <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
              <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
              <g id="SVGRepo_iconCarrier">
                <path
                  d="M11 8C11 7.44772 11.4477 7 12 7C12.5523 7 13 7.44772 13 8V11H16C16.5523 11 17 11.4477 17 12C17 12.5523 16.5523 13 16 13H13V16C13 16.5523 12.5523 17 12 17C11.4477 17 11 16.5523 11 16V13H8C7.44771 13 7 12.5523 7 12C7 11.4477 7.44772 11 8 11H11V8Z"
                  fill="#2ac666"
                >
                </path>

                <path
                  fill-rule="evenodd"
                  clip-rule="evenodd"
                  d="M23 12C23 18.0751 18.0751 23 12 23C5.92487 23 1 18.0751 1 12C1 5.92487 5.92487 1 12 1C18.0751 1 23 5.92487 23 12ZM3.00683 12C3.00683 16.9668 7.03321 20.9932 12 20.9932C16.9668 20.9932 20.9932 16.9668 20.9932 12C20.9932 7.03321 16.9668 3.00683 12 3.00683C7.03321 3.00683 3.00683 7.03321 3.00683 12Z"
                  fill="#2ac666"
                >
                </path>
              </g>
            </svg>
          </.button>
          <.inputs_for :let={f} field={@form[:commands]}>
            <div class="grid grid-cols-7 gap-4 mb-2">
              <div class="col-span-3">
                <.input field={f[:name]} label="Name" type="text" />
              </div>
              <div class="col-span-3">
                <.input field={f[:command]} label="Command" type="text" />
              </div>
              <.button
                type="button"
                phx-click="remove_command_fields"
                phx-value-index={f.index}
                phx-target={@myself}
                class="flex justify-center pt-9"
              >
                <svg
                  fill="#ee3f3f"
                  width="1.15rem"
                  height="1.15rem"
                  viewBox="0 0 16 16"
                  xmlns="http://www.w3.org/2000/svg"
                  stroke="#ee3f3f"
                >
                  <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                  <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                  <g id="SVGRepo_iconCarrier">
                    <path
                      d="M0 14.545L1.455 16 8 9.455 14.545 16 16 14.545 9.455 8 16 1.455 14.545 0 8 6.545 1.455 0 0 1.455 6.545 8z"
                      fill-rule="evenodd"
                    >
                    </path>
                  </g>
                </svg>
              </.button>
            </div>
            <.input
              field={f[:fail]}
              type="checkbox"
              label="Fail if output does not match"
              phx-click="toggle_expected_output"
            />
            <.input field={f[:expected_output]} label="Expected output" type="text" />
          </.inputs_for>
        </div>

        <div>
          <label>Add test support file</label>
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

  def handle_event("add_command_fields", _, socket) do
    existing_availability =
      Ecto.Changeset.get_change(
        socket.assigns.form.source,
        :commands,
        Ecto.Changeset.get_field(socket.assigns.form.source, :commands)
      )

    changeset =
      Ecto.Changeset.put_assoc(
        socket.assigns.form.source,
        :commands,
        existing_availability ++ [%Command{}]
      )

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("remove_command_fields", %{"index" => index}, socket) do
    index = String.to_integer(index)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_field(changeset, :commands)
        {to_delete, rest} = List.pop_at(existing, index)

        commands =
          if Ecto.Changeset.change(to_delete).data.id do
            List.replace_at(existing, index, Ecto.Changeset.change(to_delete, delete: true))
          else
            rest
          end

        changeset
        |> Ecto.Changeset.put_assoc(:commands, commands)
        |> to_form()
      end)

    {:noreply, socket}
  end

  defp save_assignment_test(socket, :edit_assignment_test, assignment_test_params) do
    case AssignmentTests.update_assignment_test(
           socket.assigns.assignment_test,
           assignment_test_params
         ) do
      {:ok, assignment_test} ->
        {:ok, test_support_file} =
          AssignmentTests.save_test_support_file(%{"assignment_test_id" => assignment_test.id})

        consume_entries(socket, test_support_file)
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
        {:ok, test_support_file} =
          AssignmentTests.save_test_support_file(%{"assignment_test_id" => assignment_test.id})

        consume_entries(socket, test_support_file)

        notify_parent({:saved, assignment_test})

        {:noreply,
         socket
         |> put_flash(:info, "Assignment test created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp consume_entries(socket, test_support_file) do
    consume_uploaded_entries(socket, :test_support_file, fn meta, entry ->
      AssignmentTests.upload_test_support_file(test_support_file, %{
        "file" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: meta.path
        }
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
