defmodule Handin.AssignmentSubmission.StudentAssignmentSubmissionFile do
  use Handin.Schema
  use Waffle.Ecto.Schema

  alias Handin.AssignmentSubmission.StudentAssignmentSubmission

  import Ecto.Changeset
  @type t :: %__MODULE__{}

  schema "student_assignment_submission_files" do
    field :file, Handin.AssignmentSubmissionFileUploader.Type

    belongs_to :student_assignment_submission, StudentAssignmentSubmission
    timestamps(type: :utc_datetime)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:student_assignment_submission_id])
    |> validate_required([:student_assignment_submission_id])
  end

  def file_changeset(student_assignment_submission_file, attrs) do
    student_assignment_submission_file
    |> cast_attachments(attrs, [:file])
    |> validate_required([:file])
  end
end
