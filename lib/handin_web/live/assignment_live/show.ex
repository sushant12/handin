defmodule HandinWeb.AssignmentLive.Show do
  use HandinWeb, :live_view

  alias Handin.{Assignments, ProgrammingLanguages}
  alias Handin.AssignmentTests.{TestSupportFile, AssignmentTest}
  alias Handin.AssignmentTests

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
     |> assign(:assignment, Assignments.get_assignment!(assignment_id))
     |> assign(:assignment_test, %AssignmentTest{})
     |> stream(
       :assignment_tests,
       AssignmentTests.list_assignment_tests_for_assignment(assignment_id)
     )
     |> assign(:test_support_file, %TestSupportFile{})
     |> assign(:uploaded_files, [])
     |> allow_upload(:test_support_file,
       accept: :any,
       max_entries: 1,
       max_file_size: 1_500_000
     )}
  end

  defp page_title(:show), do: "Show Assignment"
  defp page_title(:edit), do: "Edit Assignment"
  defp page_title(:new_test), do: "New Assignment test"

  @impl true
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"test_id" => test_id}, socket) do
    assignment_test = AssignmentTests.get_assignment_test!(test_id)
    {:ok, _} = AssignmentTests.delete_assignment_test(assignment_test)

    {:noreply, stream_delete(socket, :assignment_tests, assignment_test)}
  end

  @impl true
  def handle_event("delete", %{"test_support_file_id" => test_support_file_id}, socket) do
    test_support_file = AssignmentTests.get_test_support_file!(test_support_file_id)
    {:ok, _} = AssignmentTests.delete_test_support_file(test_support_file)

    {:noreply, stream_delete(socket, :test_support_files, test_support_file)}
  end

  @impl true
  def handle_info({HandinWeb.AssignmentLive.AssignmentTestComponent, {:saved, assignment_test}}, socket) do
    {:noreply, stream_insert(socket, :assignment_tests, assignment_test)}
  end
end
