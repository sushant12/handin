defmodule Handin.AssignmentSubmission.AssignmentSubmission do
  alias Handin.AssignmentSubmission.AssignmentSubmissionFile
  alias Handin.Accounts.User
  alias Handin.Assignments.Assignment
  use Handin.Schema

  import Ecto.Changeset
  @type t :: %__MODULE__{}
  schema "assignment_submissions" do
    field :submitted_at, :utc_datetime

    belongs_to :user, User
    belongs_to :assignment, Assignment
    has_many :assignment_submission_files, AssignmentSubmissionFile

    timestamps(type: :utc_datetime)
  end

  @attrs [:submitted_at, :user_id, :assignment_id]
  def changeset(assignment_submission, attrs) do
    assignment_submission
    |> cast(attrs, @attrs)
    |> cast_assoc(:assignment_submission_files)
    |> validate_required(@attrs)
    |> unique_constraint([:assignment_id, :user_id])
  end
end
