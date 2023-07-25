defmodule Handin.Universities.University do
  use Handin.Schema
  import Ecto.Changeset

  schema "universities" do
    field :name, :string
    field :config, :map

    timestamps()
  end

  @doc false
  def changeset(university, attrs) do
    university
    |> cast(attrs, [:name, :config])
    |> validate_required([:name, :config])
  end
end
