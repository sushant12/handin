defmodule Handin.Assignments.Log do
  use Handin.Schema

  import Ecto.Changeset
  alias Handin.Assignments.Build
  @type t :: %__MODULE__{}
  schema "logs" do
    field :description, :string

    belongs_to :build, Build

    timestamps()
  end

  @attrs [:description, :build_id]
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
