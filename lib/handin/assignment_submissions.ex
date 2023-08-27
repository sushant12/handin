defmodule Handin.AssignmentSubmissions do
  alias Handin.AssignmentSubmission.StudentAssignmentSubmission
  alias Handin.AssignmentSubmission.StudentAssignmentSubmissionFile
  alias Handin.Repo

  def change_submission(assignment_submission, attrs \\ %{}) do
    assignment_submission
    |> StudentAssignmentSubmission.changeset(attrs)
  end

  def create_or_update_submission(changeset) do
    Repo.insert!(changeset,
      on_conflict: [set: [updated_at: DateTime.utc_now()]],
      conflict_target: [:user_id, :assignment_id],
      returning: true
    )
  end

  def save_assignment_submission_file(attrs) do
    StudentAssignmentSubmissionFile.changeset(attrs)
    |> Repo.insert!()
    |> Repo.preload(student_assignment_submission: [:user, :assignment])
  end

  def upload_assignment_submission_file(student_assignment_submission_file, attrs) do
    student_assignment_submission_file
    |> StudentAssignmentSubmissionFile.file_changeset(attrs)
    |> Repo.update!()
  end

  def get_user_assignment_submission(user_id) do
    Repo.get_by(StudentAssignmentSubmission, user_id: user_id)
    |> Repo.preload(:student_assignment_submission_files)
  end
end
