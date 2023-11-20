defmodule Handin.Assignments.Log do
  use Handin.Schema

  import Ecto.Changeset
  alias Handin.Assignments.{Build, Command}
  @type t :: %__MODULE__{}
  schema "logs" do
    field :description, :string

    belongs_to :build, Build

    belongs_to :command, Command

    timestamps(type: :utc_datetime_usec)
  end

  @attrs [:description, :build_id]
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
