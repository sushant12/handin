defmodule HandinWeb.TeachingAssistantLive.Show do
  use HandinWeb, :live_view

  alias Handin.{Modules, Accounts, Repo}
  alias Handin.Accounts.User
  alias Handin.Modules.ModulesInvitations

  @impl true
  def render(assigns) do
    ~H"""
    <.breadcrumbs>
      <:item text="Home" href={~p"/"} />
      <:item text="Modules" href={~p"/modules"} />
      <:item text={@module.name} href={~p"/modules/#{@module.id}/assignments"} />
      <:item text="Students" href={~p"/modules/#{@module.id}/students"} />
      <:item text={@student.email} href={~p"/modules/#{@module.id}/students"} />
    </.breadcrumbs>

    <%= if @student do %>
      <div class="w-1/2 px-4 py-8">
        <div class="p-4">
          <h2 class="text-xl font-medium mb-4">Student Details</h2>
          <div class="flex items-center mb-4">
            <span class="text-gray-700 font-medium mr-2">Email:</span>
            <span class="text-gray-900"><%= @student.email %></span>
          </div>
          <%= if @student.university_id do %>
            <div class="flex items-center mb-5">
              <span class="text-gray-700 font-medium">Confirmed At:</span>
              <span class="text-gray-900 mx-2">
                <%= @student.confirmed_at || "Not confirmed yet" %>
              </span>
              <button
                :if={!@student.confirmed_at}
                class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
                phx-click="confirm_student"
                phx-value-user_id={@student.id}
                data-confirm="Do you want to confirm the student?"
              >
                Confirm Now
              </button>
            </div>

            <h3 class="text-lg font-medium mb-2">Builds</h3>
            <div class="divide-y">
              <div :for={build <- @student.builds} class="text-gray-700 flex p-4">
                <div>Machine ID: <%= build.machine_id %></div>
                <div class="whitespace-nowrap ml-4">
                  Status:
                  <span class={[
                    build.status == :running && "text-blue-500",
                    build.status == :completed && "text-green-500",
                    build.status == :failed && "text-red-500"
                  ]}>
                    <%= build.status %>
                  </span>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    <% end %>
    """
  end

  @impl true
  def mount(%{"id" => id, "user_id" => user_id}, _session, socket) do
    with true <-
           Accounts.enrolled_module?(socket.assigns.current_user, id) ||
             socket.assigns.current_user.role in [:admin, :teaching_assistant] do
      module = Modules.get_module!(id)

      socket =
        case Accounts.get_user(user_id) || Modules.get_modules_invitations(user_id) do
          %User{} = student ->
            builds =
              Enum.filter(student.builds, &Modules.assignment_exists?(id, &1.assignment_id))

            socket |> assign(:student, Map.put(student, :builds, builds))

          %ModulesInvitations{} = module_invitation ->
            socket
            |> assign(:student, %User{id: module_invitation.id, email: module_invitation.email})

          _ ->
            socket |> assign(:student, nil)
        end

      {:ok, socket |> assign(:module, module)}
    else
      false ->
        {:ok,
         push_navigate(socket, to: ~p"/modules/#{id}/assignments")
         |> put_flash(:error, "You are not authorized to view this page")}
    end
  end

  @impl true
  def handle_event("confirm_student", %{"user_id" => user_id}, socket) do
    student =
      Accounts.get_user!(user_id)
      |> User.confirm_changeset()
      |> Repo.update!()
      |> Repo.preload(:builds)

    builds =
      Enum.filter(
        student.builds,
        &Modules.assignment_exists?(socket.assigns.module.id, &1.assignment_id)
      )

    {:noreply, socket |> assign(:student, Map.put(student, :builds, builds))}
  end
end
