defmodule HandinWeb.Admin.AssignmentTestController do
  use HandinWeb, :controller

  alias Handin.AssignmentTests
  alias Handin.Assignments.AssignmentTest

  plug(:put_root_layout, {HandinWeb.Layouts, "torch.html"})
  plug(:put_layout, false)

  def index(conn, %{"assignment_id" => assignment_id} = params) do
    case AssignmentTests.paginate_assignment_tests(params) do
      {:ok, assigns} ->
        render(conn, :index, assigns)

      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Assignment tests. #{inspect(error)}")
        |> redirect(to: ~p"/admin/assignments/#{assignment_id}")
    end
  end

  def new(conn, %{"assignment_id" => assignment_id}) do
    changeset = AssignmentTests.change_assignment_test(%AssignmentTest{})
    render(conn, :new, changeset: changeset, assignment_id: assignment_id)
  end

  def create(conn, %{"assignment_test" => assignment_test_params}) do
    case AssignmentTests.create_assignment_test(assignment_test_params) do
      {:ok, assignment_test} ->
        conn
        |> put_flash(:info, "Assignment test created successfully.")
        |> redirect(to: ~p"/admin/assignments/#{assignment_test.assignment_id}/")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "assignment_id" => assignment_id}) do
    assignment_test = AssignmentTests.get_assignment_test!(id)
    render(conn, :show, assignment_test: assignment_test, assignment_id: assignment_id)
  end

  def edit(conn, %{"id" => id, "assignment_id" => assignment_id}) do
    assignment_test = AssignmentTests.get_assignment_test!(id)
    changeset = AssignmentTests.change_assignment_test(assignment_test)

    render(conn, :edit,
      assignment_test: assignment_test,
      changeset: changeset,
      assignment_id: assignment_id
    )
  end

  def update(conn, %{
        "id" => id,
        "assignment_test" => assignment_test_params,
        "assignment_id" => assignment_id
      }) do
    assignment_test = AssignmentTests.get_assignment_test!(id)

    case AssignmentTests.update_assignment_test(assignment_test, assignment_test_params) do
      {:ok, assignment_test} ->
        conn
        |> put_flash(:info, "Assignment test updated successfully.")
        |> redirect(
          to: ~p"/admin/assignments/#{assignment_id}/assignment_tests/#{assignment_test}"
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          assignment_test: assignment_test,
          changeset: changeset,
          assignment_id: assignment_id
        )
    end
  end

  def delete(conn, %{"id" => id, "assignment_id" => assignment_id}) do
    assignment_test = AssignmentTests.get_assignment_test!(id)
    {:ok, _assignment_test} = AssignmentTests.delete_assignment_test(assignment_test)

    conn
    |> put_flash(:info, "Assignment test deleted successfully.")
    |> redirect(to: ~p"/admin/assignments/#{assignment_id}/")
  end
end
