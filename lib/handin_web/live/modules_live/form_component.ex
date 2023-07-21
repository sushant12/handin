defmodule HandinWeb.ModulesLive.FormComponent do
  use HandinWeb, :live_component
  alias Handin.Modules
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage match records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="match-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:code]} type="text" label="Code" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Match</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{modulee: match} = assigns, socket) do
    changeset = Modules.change_module(match)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"module" => match_params}, socket) do
    changeset =
      socket.assigns.modulee
      |> Modules.change_module(match_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"module" => match_params}, socket) do
    save_module(socket, socket.assigns.action, match_params)
  end

  defp save_module(socket, :edit, match_params) do
    case Modules.update_module(socket.assigns.modulee, match_params) do
      {:ok, match} ->
        notify_parent({:saved, match})

        {:noreply,
         socket
         |> put_flash(:info, "Match updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_module(socket, :new, match_params) do
    case Modules.create_module(match_params) do
      {:ok, match} ->
        notify_parent({:saved, match})

        {:noreply,
         socket
         |> put_flash(:info, "Match created successfully")
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
