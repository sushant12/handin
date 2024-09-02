defmodule HandinWeb.AssignmentLive.Detail do
  use HandinWeb, :live_view
  alias Handin.{Modules, Assignments}

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
    <%= if @module_user.role != :student do %>
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
    <%= if @module_user.role == :student do %>
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
        <%= ((@custom_assignment_date && @custom_assignment_date.start_date) || @assignment.start_date)
        |> Handin.DisplayHelper.format_date(@current_user.university.timezone) %>
      </:item>
      <:item title="Due Date">
        <%= ((@custom_assignment_date && @custom_assignment_date.due_date) || @assignment.due_date)
        |> Handin.DisplayHelper.format_date(@current_user.university.timezone) %>
      </:item>
      <:item
        :if={
          if @custom_assignment_date,
            do: @custom_assignment_date.enable_cutoff_date,
            else: @assignment.enable_cutoff_date
        }
        title="Cut off Date"
      >
        <%= ((@custom_assignment_date && @custom_assignment_date.cutoff_date) ||
               @assignment.cutoff_date)
        |> Handin.DisplayHelper.format_date(@current_user.university.timezone) %>
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
    user = socket.assigns.current_user

    with {:ok, module} <- Modules.get_module(id),
         {:ok, module_user} <-
           Modules.module_user(module, user),
         {:ok, assignment} <- Assignments.get_assignment(assignment_id, module.id) do
      custom_assignment_date =
        if user.role == :student do
          Assignments.get_custom_assignment_date_by_user_and_assignment(
            user.id,
            assignment.id
          )
        end

      {:ok,
       socket
       |> assign(current_page: :modules)
       |> assign(:module, module)
       |> assign(:page_title, "#{module.name} - #{assignment.name}")
       |> assign(:assignment, assignment)
       |> assign(:module_user, module_user)
       |> assign(:custom_assignment_date, custom_assignment_date)}
    else
      {:error, reason} ->
        {:ok,
         push_navigate(socket, to: ~p"/modules/#{id}/assignments")
         |> put_flash(:error, reason)}
    end
  end
end
