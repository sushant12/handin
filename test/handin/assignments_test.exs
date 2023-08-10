defmodule Handin.AssignmentsTest do
  use Handin.DataCase

  alias Handin.Assignments
  alias Handin.Repo

  describe "assignments" do
    alias Handin.Assignments.Assignment

    @invalid_attrs %{
      name: nil,
      max_attempts: nil,
      total_marks: nil,
      start_date: nil,
      due_date: nil,
      cutoff_date: nil,
      penalty_per_day: nil
    }

    setup do
      programming_language = insert!(:programming_language)
      module = insert!(:module)

      assignment =
        insert!(:assignment,
          programming_language_id: programming_language.id,
          module_id: module.id
        )

      %{assignment: assignment, programming_language: programming_language, module: module}
    end

    test "list_assignments/0 returns all assignments", %{assignment: assignment} do
      assert Assignments.list_assignments() == [assignment]
    end

    test "get_assignment!/1 returns the assignment with given id", %{assignment: assignment} do
      assert Assignments.get_assignment!(assignment.id) == Repo.preload(assignment, :programming_language)
    end

    test "create_assignment/1 with valid data creates a assignment", %{
      programming_language: programming_language,
      module: module
    } do
      valid_attrs = %{
        name: "some name",
        max_attempts: 42,
        total_marks: 42,
        start_date: ~U[2023-07-22 12:41:00Z],
        due_date: ~U[2023-07-22 12:41:00Z],
        cutoff_date: ~U[2023-07-22 12:41:00Z],
        penalty_per_day: 120.5,
        programming_language_id: programming_language.id,
        module_id: module.id
      }

      assert {:ok, %Assignment{} = assignment} = Assignments.create_assignment(valid_attrs)
      assert assignment.name == "some name"
      assert assignment.max_attempts == 42
      assert assignment.total_marks == 42
      assert assignment.start_date == ~U[2023-07-22 12:41:00Z]
      assert assignment.due_date == ~U[2023-07-22 12:41:00Z]
      assert assignment.cutoff_date == ~U[2023-07-22 12:41:00Z]
      assert assignment.penalty_per_day == 120.5
      assert assignment.programming_language_id == programming_language.id
      assert assignment.module_id == module.id
    end

    test "create_assignment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assignments.create_assignment(@invalid_attrs)
    end

    test "update_assignment/2 with valid data updates the assignment", %{
      assignment: assignment
    } do
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

    test "update_assignment/2 with invalid data returns error changeset", %{
      assignment: assignment
    } do
      assert {:error, %Ecto.Changeset{}} =
               Assignments.update_assignment(assignment, @invalid_attrs)

      assert Repo.preload(assignment, :programming_language)  == Assignments.get_assignment!(assignment.id)
    end

    test "delete_assignment/1 deletes the assignment", %{assignment: assignment} do
      assert {:ok, %Assignment{}} = Assignments.delete_assignment(assignment)
      assert_raise Ecto.NoResultsError, fn -> Assignments.get_assignment!(assignment.id) end
    end

    test "change_assignment/1 returns a assignment changeset", %{assignment: assignment} do
      assert %Ecto.Changeset{} = Assignments.change_assignment(assignment)
    end
  end
end
