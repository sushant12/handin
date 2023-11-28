defmodule Handin.Assignments.AssignmentTest do
  use Handin.Schema
  import Ecto.Changeset
  alias Handin.Assignments.{Assignment, Log}

  schema "assignment_tests" do
    field :name, :string
    field :points_on_pass, :float
    field :points_on_fail, :float
    field :command, :string
    field :expected_output_type, :string
    field :expected_output_text, :string
    field :expected_output_file, :string
    field :ttl, :integer

    belongs_to :assignment, Assignment

    has_many :logs, Log

    timestamps()
  end

  @required_attrs [
    :name,
    :assignment_id,
    :points_on_pass,
    :points_on_fail,
    :command,
    :expected_output_type
  ]

  @attrs @required_attrs ++ [
    :expected_output_text,
    :expected_output_file,
    :ttl
  ]

  @doc false
  def changeset(assignment_test, attrs) do
    assignment_test
    |> cast(attrs, @attrs)
    |> validate_required(@required_attrs)
  end
end
