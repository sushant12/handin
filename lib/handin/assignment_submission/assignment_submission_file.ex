defmodule Handin.AssignmentSubmissions.AssignmentSubmissionFile do
  use Handin.Schema
  use Waffle.Ecto.Schema

  alias Handin.AssignmentSubmissions.AssignmentSubmission

  import Ecto.Changeset
  @type t :: %__MODULE__{}

  schema "assignment_submission_files" do
    field :file, Handin.AssignmentSubmissionFileUploader.Type

    belongs_to :assignment_submission, AssignmentSubmission
    timestamps(type: :utc_datetime)
  end

  def changeset(assignment_submission, attrs) do
    assignment_submission
    |> cast(attrs, [:assignment_submission_id])
    |> validate_required([:assignment_submission_id])
  end

  def file_changeset(assignment_submission_file, attrs) do
    assignment_submission_file
    |> cast_attachments(attrs, [:file])
    |> validate_required([:file])
  end
end
