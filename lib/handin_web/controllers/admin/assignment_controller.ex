defmodule HandinWeb.Admin.AssignmentController do
  use HandinWeb, :controller

  alias Handin.{Assignments, Repo}
  alias Handin.Assignments.Assignment

  plug(:put_root_layout, {HandinWeb.Layouts, "torch.html"})
  plug(:put_layout, false)

  def index(conn, params) do
    case Assignments.paginate_assignments(params) do
      {:ok, %{assignments: assignments} = assigns} ->
        assignments = Repo.preload(assignments, [:module])

        render(conn, :index, Map.put(assigns, :assignments, assignments))

      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Assignments. #{inspect(error)}")
        |> redirect(to: ~p"/admin/assignments")
    end
  end

  def new(conn, _params) do
    changeset = Assignments.change_assignment(%Assignment{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"assignment" => assignment_params}) do
    assignment_params =
      Map.put(assignment_params, "timezone", conn.assigns.current_user.university.timezone)

    case Assignments.create_assignment(assignment_params) do
      {:ok, assignment} ->
        conn
        |> put_flash(:info, "Assignment created successfully.")
        |> redirect(to: ~p"/admin/assignments/#{assignment}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    render(conn, :show, assignment: assignment)
  end

  def edit(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    changeset = Assignments.change_assignment(assignment)
    render(conn, :edit, assignment: assignment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "assignment" => assignment_params}) do
    assignment = Assignments.get_assignment!(id)

    case Assignments.update_assignment(assignment, assignment_params) do
      {:ok, assignment} ->
        conn
        |> put_flash(:info, "Assignment updated successfully.")
        |> redirect(to: ~p"/admin/assignments/#{assignment}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, assignment: assignment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    {:ok, _assignment} = Assignments.delete_assignment(assignment)

    conn
    |> put_flash(:info, "Assignment deleted successfully.")
    |> redirect(to: ~p"/admin/assignments")
  end
end
