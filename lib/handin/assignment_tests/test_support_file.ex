defmodule Handin.AssignmentTests.TestSupportFile do
  use Handin.Schema
  import Ecto.Changeset
  use Waffle.Ecto.Schema

  alias Handin.AssignmentTests.AssignmentTest

  schema "test_support_files" do
    field :file, Handin.TestSupportFileUploader.Type

    belongs_to :assignment_test, AssignmentTest

    timestamps()
  end

  def changeset(test_support_file, attrs) do
    test_support_file
    |> cast(attrs, [:assignment_test_id])
    |> cast_attachments(attrs, [:file])
    |> validate_required([:assignment_test_id, :file])
  end
end
