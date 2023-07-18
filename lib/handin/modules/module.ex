defmodule Handin.Modules.Module do
  use Ecto.Schema
  import Ecto.Changeset
  alias Handin.Courses.Course
  alias Handin.Accounts.User
  alias Handin.{ModulesCourses, ModulesStudents}

  schema "module" do
    field :name, :string
    field :code, :string
    field :deleted_at, :utc_datetime

    has_one :teacher, User
    many_to_many :courses, Course, join_through: ModulesCourses
    many_to_many :students, User, join_through: ModulesStudents

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
