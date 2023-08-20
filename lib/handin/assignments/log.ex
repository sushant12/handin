defmodule Handin.Assignments.Log do
  use Handin.Schema

  import Ecto.Changeset
  alias Handin.Assignments.AssignmentTest
  @type t :: %__MODULE__{}
  schema "logs" do
    field :description, :string

    belongs_to :assignment_test, AssignmentTest

    timestamps()
  end

  @attrs [:description, :assignment_test_id]
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
