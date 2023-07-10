defmodule Handin.ModulesCourses do
  use Ecto.Schema
  import Ecto.Changeset

  schema "modules_courses" do
    belongs_to :module, Handin.Modules.Module
    belongs_to :course, Handin.Courses.Course

    timestamps()
  end

  def changeset(module_course, attrs) do
    module_course
    |> cast(attrs, [:module_id, :course_id])
    |> validate_required([:module_id, :course_id])
  end

  def check_exists?(module_id, course_id) do
    if Handin.Repo.get_by(__MODULE__, module_id: module_id, course_id: course_id) do
      true
    else
      false
    end
  end
end
