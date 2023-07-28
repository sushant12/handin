defmodule HandinWeb.ModulesLive.Show do
  alias Handin.Modules
  use HandinWeb, :live_view

  @impl true
  def mount(%{"id" => id} = params, _session, socket) do
    users = Modules.list_users(id)
    lecturers = Enum.filter(users, &(Enum.find(&1.roles, fn role -> role.name == "lecturer" end)))
    tas = Enum.filter(users, &(Enum.find(&1.roles, fn role -> role.name == "teaching_assistant" end)))
    students = Enum.filter(users, &(Enum.find(&1.roles, fn role -> role.name == "student" end)))
    {:ok, stream(socket , :lecturers, lecturers) |> stream(:tas, tas) |> stream(:students, students)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    apply_action(socket, socket.assigns.live_action, params)
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    user = socket.assigns.current_user |> Handin.Repo.preload(:modules)
    module = user.modules |> Enum.find(&(&1.id == id))

    if module do
      {:noreply, assign(socket, :module, module) |> assign(:title, nil)}
    else
      {:noreply, push_navigate(socket, to: "/modules/")}
    end
  end

  defp apply_action(socket, :add_member, %{"id" => id, "member" => member}) do
    {:noreply, assign(socket, :title, member) |> assign(:module, Modules.get_module!(id))}
  end
end
