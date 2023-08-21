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
    |> cast(attrs, [:name, :fail, :command, :expected_output, :response])
    |> validate_required([:name, :command])
    |> maybe_validate_expected_output()
  end

  defp maybe_validate_expected_output(changeset) do
    case get_field(changeset, :fail) do
      true ->
        changeset
        |> validate_required([:expected_output])

      false ->
        changeset
    end
  end
end
