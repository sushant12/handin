defmodule HandinWeb.Admin.AssignmentSubmissionController do
  use HandinWeb, :controller

  alias Handin.AssignmentSubmissions
  alias Handin.AssignmentSubmissions.AssignmentSubmission
  alias Handin.Repo

  plug(:put_root_layout, {HandinWeb.Layouts, "torch.html"})
  plug(:put_layout, false)

  def index(conn, params) do
    case AssignmentSubmissions.paginate_assignment_submissions(params) do
      {:ok, %{assignment_submissions: assignment_submissions} = assigns} ->
        render(
          conn,
          :index,
          Map.put(
            assigns,
            :assignment_submissions,
            Repo.preload(assignment_submissions, [:user, :assignment])
          )
        )

      {:error, error} ->
        conn
        |> put_flash(
          :error,
          "There was an error rendering Assignment submissions. #{inspect(error)}"
        )
        |> redirect(to: ~p"/admin/assignment_submissions")
    end
  end

  def new(conn, _params) do
    changeset = AssignmentSubmissions.change_assignment_submission(%AssignmentSubmission{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"assignment_submission" => assignment_submission_params}) do
    case AssignmentSubmissions.create_assignment_submission(assignment_submission_params) do
      {:ok, assignment_submission} ->
        conn
        |> put_flash(:info, "Assignment submission created successfully.")
        |> redirect(to: ~p"/admin/assignment_submissions/#{assignment_submission}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    assignment_submission = AssignmentSubmissions.get_assignment_submission!(id)
    render(conn, :show, assignment_submission: assignment_submission)
  end

  def edit(conn, %{"id" => id}) do
    assignment_submission = AssignmentSubmissions.get_assignment_submission!(id)
    changeset = AssignmentSubmissions.change_assignment_submission(assignment_submission)
    render(conn, :edit, assignment_submission: assignment_submission, changeset: changeset)
  end

  def update(conn, %{"id" => id, "assignment_submission" => assignment_submission_params}) do
    assignment_submission = AssignmentSubmissions.get_assignment_submission!(id)

    case AssignmentSubmissions.update_assignment_submission(
           assignment_submission,
           assignment_submission_params
         ) do
      {:ok, assignment_submission} ->
        conn
        |> put_flash(:info, "Assignment submission updated successfully.")
        |> redirect(to: ~p"/admin/assignment_submissions/#{assignment_submission}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, assignment_submission: assignment_submission, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    assignment_submission = AssignmentSubmissions.get_assignment_submission!(id)

    {:ok, _assignment_submission} =
      AssignmentSubmissions.delete_assignment_submission(assignment_submission)

    conn
    |> put_flash(:info, "Assignment submission deleted successfully.")
    |> redirect(to: ~p"/admin/assignment_submissions")
  end
end
