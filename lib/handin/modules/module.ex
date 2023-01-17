defmodule Handin.Modules.Module do
  use Ecto.Schema
  import Ecto.Changeset

  alias Handin.ModulesStudents

  schema "modules" do
    field :name, :string
    many_to_many :courses, Handin.Courses.Course, join_through: "modules_courses"
    many_to_many :students, Handin.Accounts.User, join_through: ModulesStudents

    timestamps()
  end

  @doc false
  def changeset(module, attrs) do
    module
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
