defmodule HandinWeb.ModulesLive.FormComponent do
  use HandinWeb, :live_component
  alias Handin.Modules
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage module records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="module-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:code]} type="text" label="Code" />
        <:actions>
          <.button phx-disable-with="Saving...">Save module</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{modulee: module} = assigns, socket) do
    changeset = Modules.change_module(module)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"module" => module_params}, socket) do
    changeset =
      socket.assigns.modulee
      |> Modules.change_module(module_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"module" => module_params}, socket) do
    save_module(socket, socket.assigns.action, module_params, socket.assigns.current_user.id)
  end

  defp save_module(socket, :edit, module_params, _user_id) do
    case Modules.update_module(socket.assigns.modulee, module_params) do
      {:ok, module} ->
        notify_parent({:saved, module})

        {:noreply,
         socket
         |> put_flash(:info, "module updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_module(socket, :new, module_params, user_id) do
    case Modules.create_module(module_params, user_id) do
      {:ok, module} ->
        notify_parent({:saved, module})

        {:noreply,
         socket
         |> put_flash(:info, "module created successfully")
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
