defmodule Handin.ProgrammingLanguagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Handin.ProgrammingLanguages` context.
  """

  @doc """
  Generate a programming_language.
  """
  def programming_language_fixture(attrs \\ %{}) do
    {:ok, programming_language} =
      attrs
      |> Enum.into(%{
        name: "some name",
        docker_file_url: "some docker_file_url"
      })
      |> Handin.ProgrammingLanguages.create_programming_language()

    programming_language
  end
end
