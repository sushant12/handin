defmodule Handin.Assignments.Log do
  use Handin.Schema

  import Ecto.Changeset
  alias Handin.Assignments.{Build, AssignmentTest}
  @type t :: %__MODULE__{}
  schema "logs" do
    field :output, :string
    field :command, :string
    belongs_to :build, Build
    belongs_to :assignment_test, AssignmentTest

    timestamps(type: :utc_datetime_usec)
  end

  @attrs [:output, :build_id, :command, :assignment_test_id]
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @attrs)
  end
end
