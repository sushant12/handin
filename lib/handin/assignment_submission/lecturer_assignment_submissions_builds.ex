defmodule Handin.AssignmentSubmission.LecturerAssignmentSubmissionsBuilds do
  use Handin.Schema
  import Ecto.Changeset
  @type t :: %__MODULE__{}

  schema "lecturer_assignment_submissions_builds" do
    belongs_to :assignment_submission, Handin.AssignmentSubmission.AssignmentSubmission
    belongs_to :build, Handin.Assignments.Build
    field :deleted_at, :utc_datetime

    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:assignment_submission_id, :build_id, :deleted_at])
    |> validate_required([:assignment_submission_id, :build_id])
    |> unique_constraint([:assignment_submission_id, :build_id])
  end
end
