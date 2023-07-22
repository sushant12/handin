defmodule HandinWeb.Admin.UniversityLive.FormComponent do
  use HandinWeb, :live_component

  alias Handin.Universities

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage university records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="university-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:config]} type="text" label="Config" />
        <:actions>
          <.button phx-disable-with="Saving...">Save University</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{university: university} = assigns, socket) do
    changeset = Universities.change_university(university)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"university" => university_params}, socket) do
    changeset =
      socket.assigns.university
      |> Universities.change_university(university_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"university" => university_params}, socket) do
    save_university(socket, socket.assigns.action, university_params)
  end

  defp save_university(socket, :edit, university_params) do
    case Universities.update_university(socket.assigns.university, university_params) do
      {:ok, university} ->
        notify_parent({:saved, university})

        {:noreply,
         socket
         |> put_flash(:info, "University updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_university(socket, :new, university_params) do
    case Universities.create_university(university_params) do
      {:ok, university} ->
        notify_parent({:saved, university})

        {:noreply,
         socket
         |> put_flash(:info, "University created successfully")
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
