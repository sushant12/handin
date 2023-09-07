defmodule Handin.Assignments.Build do
  use Handin.Schema

  import Ecto.Changeset
  alias Handin.AssignmentSubmission.{AssignmentSubmission,AssignmentSubmissionsBuilds}
  alias Handin.Assignments.AssignmentTest
  alias Handin.Assignments.Log
  @type t :: %__MODULE__{}
  schema "builds" do
    field :machine_id, :string
    field :status, :string
    belongs_to :assignment_test, AssignmentTest
    has_many :logs, Log, on_delete: :delete_all

    many_to_many :assignment_submissions, AssignmentSubmission, join_through: AssignmentSubmissionsBuilds
    timestamps(type: :utc_datetime)
  end

  @attrs [:machine_id, :assignment_test_id, :status]
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:assignment_test_id, :status])
    |> validate_required([:assignment_test_id, :status])
  end

  def update_changeset(build, attrs) do
    build
    |> cast(attrs, @attrs)
  end
end
