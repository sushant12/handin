defmodule Handin.AssignmentSubmissions do
  import Ecto.Query, warn: false
  alias Handin.AssignmentSubmission.AssignmentSubmission
  alias Handin.AssignmentSubmission.AssignmentSubmissionFile

  alias Handin.AssignmentSubmission.{
    AssignmentSubmissionsBuilds,
    LecturerAssignmentSubmissionsBuilds
  }

  alias Handin.Repo
  alias Handin.Assignments.Assignment

  def change_submission(assignment_submission, attrs \\ %{}) do
    assignment_submission
    |> AssignmentSubmission.changeset(attrs)
  end

  def create_or_update_submission(changeset) do
    Repo.insert!(changeset,
      on_conflict: [set: [updated_at: DateTime.utc_now()]],
      conflict_target: [:user_id, :assignment_id],
      returning: true
    )
  end

  def save_assignment_submission_file(attrs) do
    AssignmentSubmissionFile.changeset(attrs)
    |> Repo.insert!()
    |> Repo.preload(assignment_submission: [:user, :assignment])
  end

  def upload_file(assignment_submission_file, attrs) do
    assignment_submission_file
    |> AssignmentSubmissionFile.file_changeset(attrs)
    |> Repo.update!()
  end

  def get_assignment_submission_file!(assignment_submission_id) do
    Repo.get!(AssignmentSubmissionFile, assignment_submission_id)
  end

  def delete_assignment_submission_file!(file) do
    Repo.delete!(file)
  end

  def get_assignment_submission!(assignment_submission_id) do
    Repo.get!(AssignmentSubmission, assignment_submission_id)
    |> Repo.preload([
      :user,
      assignment_submission_files: [assignment_submission: [:user, :assignment]]
    ])
  end

  def get_submitted_assignment_submissions(assignment_id) do
    Repo.get(Assignment, assignment_id)
    |> Repo.preload(assignment_submissions: :user)
    |> Map.get(:assignment_submissions, nil)
  end

  @spec new_build(attrs :: %{assignment_submission_id: Ecto.UUID, build_id: Ecto.UUID}) ::
          {:ok, AssignmentSubmissionsBuilds.t()}
  def new_build(attrs) do
    AssignmentSubmissionsBuilds.changeset(attrs)
    |> Repo.insert()
  end

  def new_lecturers_build(attrs) do
    LecturerAssignmentSubmissionsBuilds.changeset(attrs)
    |> Repo.insert()
  end

  def get_user_assignment_submission(user_id, assignment_id) do
    AssignmentSubmission
    |> where([as], as.user_id == ^user_id and as.assignment_id == ^assignment_id)
    |> Repo.one()
    |> Repo.preload(:assignment_submission_files)
  end

  def get_builds(assignment_submission_id) do
    AssignmentSubmissionsBuilds
    |> where(
      [asb],
      asb.assignment_submission_id == ^assignment_submission_id and is_nil(asb.deleted_at)
    )
    |> order_by([asb], asc: asb.inserted_at)
    |> Repo.all()
    |> Repo.preload(build: [:logs])
  end

  def get_lecturer_builds(assignment_submission_id) do
    LecturerAssignmentSubmissionsBuilds
    |> where(
      [lasb],
      lasb.assignment_submission_id == ^assignment_submission_id and is_nil(lasb.deleted_at)
    )
    |> order_by([lasb], asc: lasb.inserted_at)
    |> Repo.all()
    |> Repo.preload(build: [:logs])
  end

  def submit_assignment(assignment_submission_id) do
    now = DateTime.utc_now()

    AssignmentSubmission
    |> where([as], as.id == ^assignment_submission_id)
    |> update([as], inc: [retries: 1], set: [submitted_at: ^now])
    |> Repo.update_all([])
  end

  def soft_delete_old_builds(assignment_submission_id) do
    AssignmentSubmissionsBuilds
    |> where([asb], asb.assignment_submission_id == ^assignment_submission_id)
    |> Repo.update_all(set: [deleted_at: DateTime.utc_now()])
  end

  def soft_delete_old_lecturer_builds(assignment_submission_id) do
    LecturerAssignmentSubmissionsBuilds
    |> where([asb], asb.assignment_submission_id == ^assignment_submission_id)
    |> Repo.update_all(set: [deleted_at: DateTime.utc_now()])
  end
end
