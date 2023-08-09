defmodule Handin.UniversitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Handin.Universities` context.
  """

  @doc """
  Generate a university.
  """
  def university_fixture(attrs \\ %{}) do
    {:ok, university} =
      attrs
      |> Enum.into(%{
        name: "some name",
        student_email_regex: "^\d+@studentmail.ul.ie$"
      })
      |> Handin.Universities.create_university()

    university
  end
end
