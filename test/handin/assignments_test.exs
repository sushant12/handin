defmodule Handin.AssignmentsTest do
  use Handin.DataCase

  alias Handin.Assignments

  describe "assignments" do
    alias Handin.Assignments.Assignment

    import Handin.AssignmentsFixtures

    @invalid_attrs %{
      name: nil,
      max_attempts: nil,
      total_marks: nil,
      start_date: nil,
      due_date: nil,
      cutoff_date: nil,
      penalty_per_day: nil
    }

    test "list_assignments/0 returns all assignments" do
      assignment = assignment_fixture()
      assert Assignments.list_assignments() == [assignment]
    end

    test "get_assignment!/1 returns the assignment with given id" do
      assignment = assignment_fixture()
      assert Assignments.get_assignment!(assignment.id) == assignment
    end

    test "create_assignment/1 with valid data creates a assignment" do
      valid_attrs = %{
        name: "some name",
        max_attempts: 42,
        total_marks: 42,
        start_date: ~U[2023-07-22 12:41:00Z],
        due_date: ~U[2023-07-22 12:41:00Z],
        cutoff_date: ~U[2023-07-22 12:41:00Z],
        penalty_per_day: 120.5
      }

      assert {:ok, %Assignment{} = assignment} = Assignments.create_assignment(valid_attrs)
      assert assignment.name == "some name"
      assert assignment.max_attempts == 42
      assert assignment.total_marks == 42
      assert assignment.start_date == ~U[2023-07-22 12:41:00Z]
      assert assignment.due_date == ~U[2023-07-22 12:41:00Z]
      assert assignment.cutoff_date == ~U[2023-07-22 12:41:00Z]
      assert assignment.penalty_per_day == 120.5
    end

    test "create_assignment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assignments.create_assignment(@invalid_attrs)
    end

    test "update_assignment/2 with valid data updates the assignment" do
      assignment = assignment_fixture()

      update_attrs = %{
        name: "some updated name",
        max_attempts: 43,
        total_marks: 43,
        start_date: ~U[2023-07-23 12:41:00Z],
        due_date: ~U[2023-07-23 12:41:00Z],
        cutoff_date: ~U[2023-07-23 12:41:00Z],
        penalty_per_day: 456.7
      }

      assert {:ok, %Assignment{} = assignment} =
               Assignments.update_assignment(assignment, update_attrs)

      assert assignment.name == "some updated name"
      assert assignment.max_attempts == 43
      assert assignment.total_marks == 43
      assert assignment.start_date == ~U[2023-07-23 12:41:00Z]
      assert assignment.due_date == ~U[2023-07-23 12:41:00Z]
      assert assignment.cutoff_date == ~U[2023-07-23 12:41:00Z]
      assert assignment.penalty_per_day == 456.7
    end

    test "update_assignment/2 with invalid data returns error changeset" do
      assignment = assignment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Assignments.update_assignment(assignment, @invalid_attrs)

      assert assignment == Assignments.get_assignment!(assignment.id)
    end

    test "delete_assignment/1 deletes the assignment" do
      assignment = assignment_fixture()
      assert {:ok, %Assignment{}} = Assignments.delete_assignment(assignment)
      assert_raise Ecto.NoResultsError, fn -> Assignments.get_assignment!(assignment.id) end
    end

    test "change_assignment/1 returns a assignment changeset" do
      assignment = assignment_fixture()
      assert %Ecto.Changeset{} = Assignments.change_assignment(assignment)
    end
  end
end
