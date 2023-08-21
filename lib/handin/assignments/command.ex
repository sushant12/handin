defmodule Handin.Assignments.Command do
  use Handin.Schema
  import Ecto.Changeset

  alias Handin.Assignments.AssignmentTest

  schema "commands" do
    field :name, :string
    field :command, :string
    field :fail, :boolean, default: false
    field :expected_output, :string
    field :response, :string

    belongs_to :assignment_test, AssignmentTest

    timestamps()
  end

  def changeset(command, attrs) do
    command
    |> cast(attrs, [:name, :fail])
    |> validate_required([:name])
    |> validate_expected_output(attrs)
  end

  defp validate_expected_output(changeset, attrs) do
    case get_field(changeset, :fail) do
      true ->
        changeset
        |> cast(attrs, [:expected_output])
        |> validate_required([:expected_output])

      false ->
        changeset
    end
  end
end
