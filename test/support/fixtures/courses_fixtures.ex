defmodule Handin.CoursesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Handin.Courses` context.
  """

  @doc """
  Generate a course.
  """
  def course_fixture(attrs \\ %{}) do
    {:ok, course} =
      attrs
      |> Enum.into(%{
        code: 42,
        name: "some name"
      })
      |> Handin.Courses.create_course()

    course
  end
end
