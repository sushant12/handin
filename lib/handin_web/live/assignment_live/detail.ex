defmodule HandinWeb.AssignmentLive.Detail do
  use HandinWeb, :live_view
  use Timex
  alias Handin.Modules
  alias Handin.Assignments

  @impl true
  def render(assigns) do
    ~H"""
    <.breadcrumbs>
      <:item text="Home" href={~p"/"} />
      <:item text="Modules" href={~p"/modules"} />
      <:item text={@module.name} href={~p"/modules/#{@module.id}/assignments"} />
      <:item
        text="Assignments"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"}
      />
      <:item
        text={@assignment.name}
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"}
        current={true}
      />
    </.breadcrumbs>
    <%= if @current_user.role != "student" do %>
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
      </.tabs>
    <% end %>
    <%= if @current_user.role == "student" do %>
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
      <span class="bg-gray-100 text-gray-800 text-xs font-medium mr-2 px-2.5 py-0.5 rounded-full dark:bg-gray-700 dark:text-gray-300">
        <%= @assignment.programming_language.name %>
      </span>
    </.header>

    <.list>
      <:item title="Total marks"><%= @assignment.total_marks %></:item>
      <:item title="Max attempts"><%= @assignment.max_attempts %></:item>
      <:item title="Penalty per day"><%= @assignment.penalty_per_day %>%</:item>
      <:item title="Start Date">
        <%= Timex.Timezone.convert(@assignment.start_date, "Europe/Dublin")
        |> Timex.format!("%b %e, %Y at %H:%M:%S %p", :strftime) %>
      </:item>
      <:item title="Due Date">
        <%= Timex.Timezone.convert(@assignment.due_date, "Europe/Dublin")
        |> Timex.format!("%b %e, %Y at %H:%M:%S %p", :strftime) %>
      </:item>
      <:item title="Cut off Date">
        <%= Timex.Timezone.convert(@assignment.cutoff_date, "Europe/Dublin")
        |> Timex.format!("%b %e, %Y at %H:%M:%S %p", :strftime) %>
      </:item>
    </.list>
    """
  end

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: :modules)
     |> assign(:module, Modules.get_module!(id))
     |> assign(:assignment, Assignments.get_assignment!(assignment_id))}
  end
end
