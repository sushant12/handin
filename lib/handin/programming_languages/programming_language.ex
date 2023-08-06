defmodule Handin.ProgrammingLanguages.ProgrammingLanguage do
  use Handin.Schema
  import Ecto.Changeset

  alias Handin.Assignments.Assignment

  schema "programming_languages" do
    field :name, :string
    field :docker_file_url, :string

    has_many :assignments, Assignment

    timestamps()
  end

  @doc false
  def changeset(programming_language, attrs) do
    programming_language
    |> cast(attrs, [:name, :docker_file_url])
    |> validate_required([:name, :docker_file_url])
  end
end
