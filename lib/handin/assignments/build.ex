defmodule Handin.Assignments.Build do
  use Handin.Schema

  import Ecto.Changeset
  alias Handin.Assignments.AssignmentTest
  alias Handin.Assignments.Log
  @type t :: %__MODULE__{}
  schema "builds" do
    field :machine_id, :string

    belongs_to :assignment_test, AssignmentTest
    has_many :logs, Log, on_delete: :delete_all
    timestamps()
  end

  @attrs [:machine_id, :assignment_test_id]
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:assignment_test_id])
    |> validate_required([:assignment_test_id])
  end

  def update_changeset(build, attrs) do
    build
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
