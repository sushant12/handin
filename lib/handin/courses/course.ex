defmodule Handin.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset
  alias Handin.ModulesCourses

  schema "courses" do
    field :code, :integer
    field :name, :string
    has_many :users, Handin.Accounts.User
    many_to_many :modules, Handin.Modules.Module, join_through: ModulesCourses

    timestamps()
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :code])
    |> validate_required([:name, :code])
  end
end
