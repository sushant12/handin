defmodule Handin.Assignments.TestSupportFile do
  use Handin.Schema
  import Ecto.Changeset
  use Waffle.Ecto.Schema

  alias Handin.Assignments.AssignmentTest

  schema "test_support_files" do
    field :file, Handin.TestSupportFileUploader.Type

    belongs_to :assignment_test, AssignmentTest

    timestamps()
  end

  def changeset(test_support_file, attrs) do
    test_support_file
    |> cast(attrs, [:assignment_test_id])
    |> validate_required([:assignment_test_id])
  end

  def file_changeset(test_support_file, attrs) do
    test_support_file
    |> cast_attachments(attrs, [:file])
    |> validate_required([:file])
  end
end
