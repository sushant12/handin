defmodule Handin.Universities.University do
  use Handin.Schema
  import Ecto.Changeset

  schema "universities" do
    field :name, :string
    field :config, :map
    field :student_email_regex, :string

    timestamps()
  end

  @doc false
  def changeset(university, attrs) do
    university
    |> cast(attrs, [:name, :config, :student_email_regex])
    |> validate_required([:name, :config, :student_email_regex])
  end
end
