defmodule HandinWeb.AssignmentLive.Show do
  use HandinWeb, :live_view

  alias Handin.{Assignments, ProgrammingLanguages}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "assignment_id" => assignment_id}, _, socket) do
    programming_languages =
      ProgrammingLanguages.list_programming_languages() |> Enum.map(&{&1.name, &1.id})

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:module_id, id)
     |> assign(:programming_languages, programming_languages)
     |> assign(:assignment, Assignments.get_assignment!(assignment_id))}
  end

  defp page_title(:show), do: "Show Assignment"
  defp page_title(:edit), do: "Edit Assignment"
end
