defmodule Handin.AssignmentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Handin.Assignments` context.
  """

  @doc """
  Generate a assignment.
  """
  def assignment_fixture(attrs \\ %{}) do
    now = NaiveDateTime.utc_now()
    start_date = NaiveDateTime.add(now, 1, :day)
    due_date = NaiveDateTime.add(now, 2, :day)
    cutoff_date = NaiveDateTime.add(now, 3, :day)
    {:ok, assignment} =
      attrs
      |> Enum.into(%{
        name: "some name #{Enum.random(1..100)}",
        max_attempts: 5,
        total_marks: 40,
        start_date: start_date,
        due_date: due_date,
        cutoff_date: cutoff_date,
        penalty_per_day: 10,
        timezone: "Europe/Dublin"
      })
      |> Handin.Assignments.create_assignment()

    assignment
  end
end
