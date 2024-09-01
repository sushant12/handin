defmodule Handin.Assignments.AssignmentFile do
  use Ecto.Schema
  import Ecto.Changeset
  use Waffle.Ecto.Schema
  alias Handin.AssignmentFileUploader
  alias Handin.Assignments.Assignment

  @type t :: %__MODULE__{}

  schema "assignment_files" do
    field :file, AssignmentFileUploader.Type
    field :file_type, Ecto.Enum, values: [:solution, :test_resource]
    belongs_to :assignment, Assignment, type: :binary_id

    timestamps()
  end

  def changeset(assignment_file, attrs) do
    assignment_file
    |> cast(attrs, [:assignment_id, :file_type])
    |> validate_required([:assignment_id, :file_type])
  end

  def file_changeset(assignment_file, attrs) do
    assignment_file
    |> cast_attachments(attrs, [:file])
    |> validate_required([:file])
  end

  def clone_changeset(assignment_file, attrs) do
    assignment_file
    |> cast(attrs, [:assignment_id, :file])
    |> validate_required([:assignment_id, :file])
  end
end
