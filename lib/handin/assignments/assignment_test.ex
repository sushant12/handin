defmodule Handin.Assignments.AssignmentTest do
  use Handin.Schema
  import Ecto.Changeset
  alias Handin.Assignments.Assignment

  schema "assignment_tests" do
    field :name, :string
    field :marks, :float

    belongs_to :assignment, Assignment

    timestamps()
  end

  @attrs [:name, :marks, :assignment_id]
  @doc false
  def changeset(assignment_test, attrs) do
    assignment_test
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
