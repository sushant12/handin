defmodule Handin.AssignmentTests.AssignmentTest do
  use Handin.Schema
  import Ecto.Changeset
  alias Handin.Assignments.Assignment

  schema "assignment_tests" do
    field :command, :string
    field :name, :string
    field :marks, :float

    belongs_to :assignment, Assignment

    timestamps()
  end

  @doc false
  def changeset(assignment_test, attrs) do
    assignment_test
    |> cast(attrs, [:name, :marks, :command])
    |> validate_required([:name, :marks, :command])
  end
end
