defmodule Handin.AssignmentSubmissions.AssignmentSubmissionTest do
  alias Handin.Assignments.AssignmentTest
  alias Handin.AssignmentSubmissions.AssignmentSubmission
  use Handin.Schema

  import Ecto.Changeset
  @type t :: %__MODULE__{}
  schema "assignment_submission_tests" do
    field :failed_at, :utc_datetime
    belongs_to :assignment_submission, AssignmentSubmission
    belongs_to :assignment_tests, AssignmentTest
    timestamps(type: :utc_datetime)
  end

  @attrs [:failed_at, :assignment_submission_id, :assignment_tests_id]
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
