defmodule Handin.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  alias Handin.Accounts.User
  alias Handin.Modules.Module
  alias Handin.ModulesCourses

  schema "course" do
    field :code, :integer
    field :name, :string

    has_many :users, User
    many_to_many :modules, Module, join_through: ModulesCourses

    timestamps()
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
  end
end
