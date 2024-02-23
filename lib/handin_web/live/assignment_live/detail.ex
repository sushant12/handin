defmodule HandinWeb.AssignmentLive.Detail do
  use HandinWeb, :live_view
  alias Handin.{Modules, Accounts, Assignments}

  @impl true
  def render(assigns) do
    ~H"""
    <.breadcrumbs>
      <:item text="Home" href={~p"/"} />
      <:item text="Modules" href={~p"/modules"} />
      <:item text={@module.name} href={~p"/modules/#{@module.id}/assignments"} />
      <:item
        text={@assignment.name}
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"}
        current={true}
      />
    </.breadcrumbs>
    <%= if @current_user.role != :student do %>
      <.tabs>
        <:item
          text="Details"
          href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"}
          current={true}
        />
        <:item
          text="Environment"
          href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/environment"}
        />
        <:item text="Tests" href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/tests"} />
        <:item
          text="Submissions"
          href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/submissions"}
        />
        <:item
          text="Settings"
          href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/settings"}
        />
      </.tabs>
    <% end %>
    <%= if @current_user.role == :student do %>
      <.tabs>
        <:item
          text="Details"
          href={~p"/modules/#{@module}/assignments/#{@assignment}/details"}
          current={true}
        />
        <:item text="Submit" href={~p"/modules/#{@module}/assignments/#{@assignment}/submit"} />
      </.tabs>
    <% end %>

    <.header>
      <%= @assignment.name %>
    </.header>

    <.list>
      <:item title="Start Date">
        <%= Handin.DisplayHelper.format_date(
          @assignment.start_date,
          @current_user.university.timezone
        ) %>
      </:item>
      <:item title="Due Date">
        <%= Handin.DisplayHelper.format_date(@assignment.due_date, @current_user.university.timezone) %>
      </:item>
      <:item :if={@assignment.enable_cutoff_date} title="Cut off Date">
        <%= Handin.DisplayHelper.format_date(
          @assignment.cutoff_date,
          @current_user.university.timezone
        ) %>
      </:item>
      <:item :if={@assignment.enable_total_marks} title="Total marks">
        <%= @assignment.total_marks %>
      </:item>
      <:item :if={@assignment.enable_max_attempts} title="Max attempts">
        <%= @assignment.max_attempts %>
      </:item>
      <:item :if={@assignment.enable_penalty_per_day} title="Penalty per day">
        <%= @assignment.penalty_per_day %>%
      </:item>
    </.list>
    """
  end

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    with true <-
           Accounts.enrolled_module?(socket.assigns.current_user, id) ||
             socket.assigns.current_user.role == :admin,
         true <- Modules.assignment_exists?(id, assignment_id) do
      module = Modules.get_module!(id)
      assignment = Assignments.get_assignment!(assignment_id)

      {:ok,
       socket
       |> assign(current_page: :modules)
       |> assign(:module, module)
       |> assign(:page_title, "#{module.name} - #{assignment.name}")
       |> assign(:assignment, assignment)}
    else
      false ->
        {:ok,
         push_navigate(socket, to: ~p"/modules/#{id}/assignments")
         |> put_flash(:error, "You are not authorized to view this page")}
    end
  end
end
