defmodule Handin.Modules.Module do
  use Ecto.Schema
  import Ecto.Changeset

  alias Handin.Accounts.User
  alias Handin.ModulesCourses
  alias Handin.ModulesStudents

  schema "modules" do
    field :name, :string
    many_to_many :courses, Handin.Courses.Course, join_through: ModulesCourses
    many_to_many :students, User, join_through: ModulesStudents
    has_one :teacher, User

    timestamps()
  end

  @doc false
  def changeset(module, attrs) do
    module
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
