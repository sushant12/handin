defmodule Handin.AssignmentTestsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Handin.AssignmentTests` context.
  """

  @doc """
  Generate a assignment_test.
  """
  def assignment_test_fixture(attrs \\ %{}) do
    {:ok, assignment_test} =
      attrs
      |> Enum.into(%{
        name: "some name",
        marks: 120.5
      })
      |> Handin.AssignmentTests.create_assignment_test()

    assignment_test
  end
end
