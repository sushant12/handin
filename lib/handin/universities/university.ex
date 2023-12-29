defmodule Handin.Universities.University do
  use Handin.Schema
  import Ecto.Changeset

  schema "universities" do
    field :name, :string
    field :student_email_regex, :string
    field :timezone, :string

    timestamps()
  end

  # need to convert student_email_regex into ~S || non escape string
  @doc false
  def changeset(university, attrs) do
    university
    |> cast(attrs, [:name, :student_email_regex, :timezone])
    |> validate_required([:name, :student_email_regex, :timezone])
  end
end
