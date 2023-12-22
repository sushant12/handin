defmodule Handin.AssignmentSubmissions do
  import Ecto.Query, warn: false
  alias Handin.Repo
  alias Handin.AssignmentSubmission.AssignmentSubmissionFile

  def get_assignment_submission_file!(assignment_submission_id) do
    Repo.get!(AssignmentSubmissionFile, assignment_submission_id)
    |> Repo.preload(assignment_submission: [:user, :assignment])
  end
end
