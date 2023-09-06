defmodule Handin.AssignmentSubmissions do
  alias Handin.AssignmentSubmission.AssignmentSubmission
  alias Handin.AssignmentSubmission.AssignmentSubmissionFile
  alias Handin.Repo

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

  def get_user_assignment_submission(user_id) do
    Repo.get_by(AssignmentSubmission, user_id: user_id)
    |> Repo.preload(:assignment_submission_files)
  end

  def validate_submission(user_id) do
    %AssignmentSubmission{retries: retries} =
      old_submission = get_user_assignment_submission(user_id)

    old_submission
    |> change_submission(%{retries: retries + 1, submitted_at: DateTime.utc_now()})
    |> Repo.update!()
  end
end
