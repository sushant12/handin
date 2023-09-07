defmodule Handin.AssignmentSubmission.AssignmentSubmissionsBuilds do
  use Handin.Schema
  import Ecto.Changeset
  @type t :: %__MODULE__{}

  schema "assignment_submissions_builds" do
    belongs_to :assignment_submission, Handin.AssignmentSubmission.AssignmentSubmission
    belongs_to :build, Handin.Assignments.Build

    timestamps()
  end

  def changeset(assignment_submission_build, attrs) do
    assignment_submission_build
    |> cast(attrs, [:assignment_submission_id, :build_id])
    |> validate_required([:assignment_submission_id, :build_id])
    |> unique_constraint([:assignment_submission_id, :build_id])
  end
end
