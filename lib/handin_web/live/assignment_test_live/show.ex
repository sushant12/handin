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
     |> assign(:test_support_file, %TestSupportFile{})
     |> stream(
       :test_support_files,
       AssignmentTests.get_test_support_files_for_test(test_id)
     )}
  end

  @impl true
  def handle_event("delete", %{"test_support_file_id" => test_support_file_id}, socket) do
    test_support_file = AssignmentTests.get_test_support_file!(test_support_file_id)
    {:ok, _} = AssignmentTests.delete_test_support_file(test_support_file)

    {:noreply, stream_delete(socket, :test_support_files, test_support_file)}
  end

  defp page_title(:show), do: "Show Assignment test"
  defp page_title(:edit), do: "Edit Assignment test"
  defp page_title(:new_file), do: "Add Assignment test support file"
end
