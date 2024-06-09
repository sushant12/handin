defmodule Handin.AssignmentsTest do
  use Handin.DataCase

  alias Handin.Assignments
  alias Handin.Assignments.Assignment
  import Handin.{ModulesFixtures, AccountsFixtures, UniversitiesFixtures, AssignmentsFixtures}

  describe "assignments" do
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
      university = university_fixture()
      lecturer = lecturer_fixture()
      module = module_fixture(%{user_id: lecturer.id})
      assignment = assignment_fixture(%{module_id: module.id})

      %{
        lecturer: lecturer,
        university: university,
        user: user_fixture(%{university: university}),
        module: module,
        assignment: assignment
      }
    end

    test "list_assignments/0 returns all assignments", %{module: module} do
      assignment_fixture(%{module_id: module.id})
      assignment_fixture(%{module_id: module.id})
      assignment_fixture(%{module_id: module.id})
      assert Enum.count( Assignments.list_assignments() ) == 4
    end

    test "get_assignment!/1 returns the assignment with given id", %{assignment: assignment} do
      assert Assignments.get_assignment!(assignment.id).id == assignment.id
    end

    test "create_assignment/1 with valid data creates a assignment", %{module: module} do
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      start_date = NaiveDateTime.add(now, 1, :day)
      due_date = NaiveDateTime.add(now, 2, :day)
      cutoff_date = NaiveDateTime.add(now, 3, :day)
      valid_attrs = %{
        name: "some name",
        max_attempts: 42,
        total_marks: 42,
        start_date: start_date,
        due_date: due_date,
        cutoff_date: cutoff_date,
        penalty_per_day: 120.5,
        timezone: "Europe/London"
      }

      assert {:ok, %Assignment{} = assignment} =
               Assignments.create_assignment(valid_attrs |> Map.put(:module_id, module.id))

      assert assignment.name == "some name"
      assert assignment.max_attempts == 42
      assert assignment.total_marks == 42
      assert assignment.start_date ==start_date
      assert assignment.due_date ==due_date
      assert assignment.cutoff_date ==cutoff_date
      assert assignment.penalty_per_day == 120.5
    end

    test "create_assignment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assignments.create_assignment(@invalid_attrs)
    end

    test "update_assignment/2 with valid data updates the assignment", %{assignment: assignment} do
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      start_date = NaiveDateTime.add(now, 1, :day)
      due_date = NaiveDateTime.add(now, 2, :day)
      cutoff_date = NaiveDateTime.add(now, 3, :day)
      update_attrs = %{
        name: "some updated name",
        max_attempts: 4,
        total_marks: 30,
        start_date: start_date,
        due_date: due_date,
        cutoff_date: cutoff_date,
        penalty_per_day: 30,
        timezone: "Europe/London"
      }

      assert {:ok, %Assignment{} = assignment} =
               Assignments.update_assignment(assignment, update_attrs)

      assert assignment.name == "some updated name"
      assert assignment.max_attempts == 4
      assert assignment.total_marks == 30
      assert assignment.start_date == start_date
      assert assignment.due_date == due_date
      assert assignment.cutoff_date == cutoff_date
      assert assignment.penalty_per_day == 30
    end

    test "update_assignment/2 with invalid data returns error changeset", %{
      assignment: %{id: assignment_id} = assignment
    } do
      assert {:error, %Ecto.Changeset{}} =
               Assignments.update_assignment(assignment, @invalid_attrs)

      assert %Assignment{id: ^assignment_id} = Assignments.get_assignment!(assignment.id)
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
