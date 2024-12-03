defmodule Handin.Assignments.AssignmentTestOutputFile do
  use Handin.Schema
  import Ecto.Changeset
  use Waffle.Ecto.Schema
  alias Handin.Assignments.AssignmentTest
  alias Handin.AssignmentSubmissions.AssignmentSubmission
  alias Handin.AssignmentTestOutputUploader

  @type t :: %__MODULE__{}

  schema "assignment_test_output_files" do
    field :file, AssignmentTestOutputUploader.Type

    belongs_to :assignment_test, AssignmentTest
    belongs_to :assignment_submission, AssignmentSubmission

    timestamps()
  end

  def changeset(assignment_test_output_file, attrs) do
    assignment_test_output_file
    |> cast(attrs, [:assignment_test_id, :assignment_submission_id])
    |> validate_required([:assignment_test_id])
  end

  def file_changeset(assignment_test_output_file, attrs) do
    assignment_test_output_file
    |> cast_attachments(attrs, [:file])
    |> validate_required([:file])
  end
end
