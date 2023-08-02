defmodule Handin.Assignments.Assignment do
  use Handin.Schema

  import Ecto.Changeset
  alias Handin.Modules.Module

  schema "assignments" do
    field :name, :string
    field :max_attempts, :integer
    field :total_marks, :integer
    field :start_date, :utc_datetime
    field :due_date, :utc_datetime
    field :cutoff_date, :utc_datetime
    field :penalty_per_day, :float

    belongs_to :module, Module

    timestamps()
  end

  @doc false
  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [
      :name,
      :total_marks,
      :start_date,
      :due_date,
      :cutoff_date,
      :max_attempts,
      :penalty_per_day
    ])
    |> validate_required([
      :name,
      :total_marks,
      :start_date,
      :due_date,
      :cutoff_date,
      :max_attempts,
      :penalty_per_day
    ])
    |> validate_number(:max_attempts, greater_than_or_equal_to: 0)
    |> validate_number(:penalty_per_day, greater_than_or_equal_to: 0)
    |> validate_number(:total_marks, greater_than_or_equal_to: 0)
  end
end
