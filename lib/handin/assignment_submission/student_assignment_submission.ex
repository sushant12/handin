defmodule Handin.AssignmentSubmission.StudentAssignmentSubmission do
  alias Handin.AssignmentSubmission.StudentAssignmentSubmissionFile
  alias Handin.Accounts.User
  alias Handin.Assignments.Assignment
  use Handin.Schema

  import Ecto.Changeset
  @type t :: %__MODULE__{}
  schema "student_assignment_submissions" do
    field :submitted_at, :utc_datetime

    belongs_to :user, User
    belongs_to :assignment, Assignment
    has_many :student_assignment_submission_files, StudentAssignmentSubmissionFile

    timestamps(type: :utc_datetime)
  end

  @attrs [:submitted_at, :user_id, :assignment_id]
  def changeset(student_assignment_submission, attrs) do
    student_assignment_submission
    |> cast(attrs, @attrs)
    |> cast_assoc(:student_assignment_submission_files)
    |> validate_required(@attrs)
    |> unique_constraint([:assignment_id, :user_id])
  end
end
