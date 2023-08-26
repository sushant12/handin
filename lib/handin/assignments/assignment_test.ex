defmodule Handin.Assignments.AssignmentTest do
  use Handin.Schema
  import Ecto.Changeset
  alias Handin.Assignments.{Assignment, TestSupportFile, Command, Build}

  schema "assignment_tests" do
    field :name, :string
    field :marks, :float

    belongs_to :assignment, Assignment

    has_many :commands, Command,
      on_delete: :delete_all,
      on_replace: :delete,
      preload_order: [asc: :inserted_at]

    has_many :test_support_files, TestSupportFile, on_delete: :delete_all
    has_many :builds, Build, on_delete: :delete_all
    timestamps()
  end

  @attrs [:name, :marks, :assignment_id]
  @doc false
  def changeset(assignment_test, attrs) do
    assignment_test
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
    |> cast_assoc(:commands, with: &Command.changeset/2)
  end
end
