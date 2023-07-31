defmodule Handin.AssignmentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Handin.Assignments` context.
  """

  @doc """
  Generate a assignment.
  """
  def assignment_fixture(attrs \\ %{}) do
    {:ok, assignment} =
      attrs
      |> Enum.into(%{
        name: "some name",
        max_attempts: 42,
        total_marks: 42,
        start_date: ~U[2023-07-22 12:41:00Z],
        due_date: ~U[2023-07-22 12:41:00Z],
        cutoff_date: ~U[2023-07-22 12:41:00Z],
        penalty_per_day: 120.5
      })
      |> Handin.Assignments.create_assignment()

    assignment
  end
end
