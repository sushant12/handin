defmodule HandinWeb.Admin.BuildLive.Edit do
  use HandinWeb, :live_component
  alias Handin.{Assignments, Accounts}
  alias Handin.Assignments.Build

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Edit build
      </.header>

      <.simple_form
        for={@form}
        id="build-edit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:machine_id]} type="text" label="Machine ID" />
        <.input
          field={@form[:status]}
          type="select"
          label="Role"
          options={[:running, :failed, :completed]}
        />
        <.input
          field={@form[:assignment_id]}
          type="select"
          label="Assignment"
          options={Assignments.list_assignments() |> Enum.map(&{&1.name, &1.id})}
        />
        <.input
          field={@form[:user_id]}
          type="select"
          label="User"
          options={Accounts.list_users() |> Enum.map(&{&1.email, &1.id})}
        />
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
  def update(%{build: build} = assigns, socket) do
    changeset = Build.update_changeset(build)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"build" => build_params}, socket) do
    changeset =
      socket.assigns.build
      |> Build.update_changeset(build_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"build" => build_params}, socket) do
    save_build(
      socket,
      socket.assigns.action,
      build_params
    )
  end

  defp save_build(socket, :edit, build_params) do
    case Assignments.update_build(socket.assigns.build, build_params) do
      {:ok, build} ->
        notify_parent({:saved, build})

        {:noreply,
         socket
         |> put_flash(:info, "Build updated successfully")
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
