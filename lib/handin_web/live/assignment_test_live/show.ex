defmodule HandinWeb.AssignmentTestLive.Show do
  use HandinWeb, :live_view

  alias Handin.AssignmentTests
  alias Handin.AssignmentTests.TestSupportFile

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(
        %{"id" => id, "assignment_id" => assignment_id, "test_id" => test_id},
        _,
        socket
      ) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:module_id, id)
     |> assign(:assignment_id, assignment_id)
     |> assign(:assignment_test, AssignmentTests.get_assignment_test!(test_id))
     |> assign(:test_support_file, %TestSupportFile{})}
  end

  defp page_title(:show), do: "Show Assignment test"
  defp page_title(:edit), do: "Edit Assignment test"
  defp page_title(:new_file), do: "Add Assignment test support file"
end
