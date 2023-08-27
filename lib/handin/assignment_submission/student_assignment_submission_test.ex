defmodule Handin.AssignmentSubmission.StudentAssignmentSubmissionTest do
  alias Handin.Assignments.AssignmentTest
  alias Handin.AssignmentSubmission.StudentAssignmentSubmission
  use Handin.Schema

  import Ecto.Changeset
  @type t :: %__MODULE__{}
  schema "student_assignment_submission_tests" do
    field :failed_at, :utc_datetime
    belongs_to :student_assignment_submission, StudentAssignmentSubmission
    belongs_to :assignment_tests, AssignmentTest
    timestamps(type: :utc_datetime)
  end

  @attrs [:failed_at, :student_assignment_submission_id, :assignment_tests_id]
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
