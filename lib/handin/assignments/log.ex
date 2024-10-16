defmodule Handin.Assignments.Log do
  use Handin.Schema

  import Ecto.Changeset
  alias Handin.Assignments.Build
  @type t :: %__MODULE__{}
  schema "logs" do
    field :output, :string
    field :type, Ecto.Enum, values: [:compilation, :runtime]
    belongs_to :build, Build

    timestamps(type: :utc_datetime_usec)
  end

  @attrs [:output, :build_id, :type]
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @attrs)
    |> validate_inclusion(:type, [:compilation, :runtime])
  end
end
