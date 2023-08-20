defmodule Handin.Assignments.AssignmentTest do
  use Handin.Schema
  import Ecto.Changeset
  alias Handin.Assignments.Assignment
  alias Handin.Assignments.TestSupportFile
  alias Handin.Assignments.Build

  schema "assignment_tests" do
    field :command, :string
    field :name, :string
    field :marks, :float

    belongs_to :assignment, Assignment
    has_many :test_support_files, TestSupportFile, on_delete: :delete_all
    has_many :builds, Build, on_delete: :delete_all
    timestamps()
  end

  @attrs [:name, :marks, :command, :assignment_id]
  @doc false
  def changeset(assignment_test, attrs) do
    assignment_test
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
