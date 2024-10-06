defmodule Handin.AssignmentsTest do
  use Handin.DataCase
  import Handin.Factory

  alias Handin.Assignments.AssignmentTest
  alias Handin.Assignments

  describe "submission_allowed?" do
    setup do
      lecturer = insert(:lecturer)
      student = insert(:student)
      module = insert(:module)

      %{lecturer: lecturer, student: student, module: module}
    end

    test "return true if custom date is set but cut off is not enabled", %{
      lecturer: lecturer,
      student: student,
      module: module
    } do
      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      insert(:modules_users, user: student, module: module, role: :student)

      assignment =
        insert(:assignment, module: module, due_date: DateTime.utc_now() |> DateTime.add(1, :day))

      insert(:custom_assignment_date, assignment: assignment, user: student)

      assignment_submission =
        insert(:assignment_submission, assignment: assignment, user: student)

      assert true == Handin.Assignments.submission_allowed?(assignment_submission)
    end

    test "return true if custom date is set and cut off is enabled", %{
      lecturer: lecturer,
      student: student,
      module: module
    } do
      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      insert(:modules_users, user: student, module: module, role: :student)

      assignment =
        insert(:assignment, module: module, due_date: DateTime.utc_now() |> DateTime.add(1, :day))

      insert(:custom_assignment_date,
        assignment: assignment,
        user: student,
        enable_cutoff_date: true,
        cutoff_date: DateTime.utc_now() |> DateTime.add(1, :day)
      )

      assignment_submission =
        insert(:assignment_submission, assignment: assignment, user: student)

      assert true == Handin.Assignments.submission_allowed?(assignment_submission)
    end

    test "return true if assignment cutoff date is set", %{
      lecturer: lecturer,
      student: student,
      module: module
    } do
      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      insert(:modules_users, user: student, module: module, role: :student)

      assignment =
        insert(:assignment,
          module: module,
          due_date: DateTime.utc_now() |> DateTime.add(1, :day),
          cutoff_date: DateTime.utc_now() |> DateTime.add(2, :day),
          enable_cutoff_date: true
        )

      assignment_submission =
        insert(:assignment_submission, assignment: assignment, user: student)

      assert true == Handin.Assignments.submission_allowed?(assignment_submission)
    end

    test "return true if assignment cutoff date is not set but due date is set", %{
      lecturer: lecturer,
      student: student,
      module: module
    } do
      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      insert(:modules_users, user: student, module: module, role: :student)

      assignment =
        insert(:assignment,
          module: module,
          due_date: DateTime.utc_now() |> DateTime.add(1, :day)
        )

      assignment_submission =
        insert(:assignment_submission, assignment: assignment, user: student)

      assert true == Handin.Assignments.submission_allowed?(assignment_submission)
    end

    test "return false if custom date's cut off date is passed", %{
      lecturer: lecturer,
      student: student,
      module: module
    } do
      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      insert(:modules_users, user: student, module: module, role: :student)

      assignment =
        insert(:assignment,
          module: module,
          due_date: DateTime.utc_now() |> DateTime.add(1, :day),
          cutoff_date: DateTime.utc_now() |> DateTime.add(2, :day)
        )

      insert(:custom_assignment_date,
        assignment: assignment,
        user: student,
        cutoff_date: DateTime.utc_now() |> DateTime.add(-1, :day),
        enable_cutoff_date: true
      )

      assignment_submission =
        insert(:assignment_submission, assignment: assignment, user: student)

      assert false == Handin.Assignments.submission_allowed?(assignment_submission)
    end

    test "return false if custom date's due date is passed", %{
      lecturer: lecturer,
      student: student,
      module: module
    } do
      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      insert(:modules_users, user: student, module: module, role: :student)

      assignment =
        insert(:assignment,
          module: module,
          due_date: DateTime.utc_now() |> DateTime.add(2, :day)
        )

      insert(:custom_assignment_date,
        assignment: assignment,
        user: student,
        due_date: DateTime.utc_now() |> DateTime.add(-1, :day)
      )

      assignment_submission =
        insert(:assignment_submission, assignment: assignment, user: student)

      assert false == Handin.Assignments.submission_allowed?(assignment_submission)
    end

    test "return false if assignment's cut off date is passed", %{
      lecturer: lecturer,
      student: student,
      module: module
    } do
      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      insert(:modules_users, user: student, module: module, role: :student)

      assignment =
        insert(:assignment,
          module: module,
          due_date: DateTime.utc_now() |> DateTime.add(-2, :day),
          cutoff_date: DateTime.utc_now() |> DateTime.add(-1, :day),
          enable_cutoff_date: true
        )

      assignment_submission =
        insert(:assignment_submission, assignment: assignment, user: student)

      assert false == Handin.Assignments.submission_allowed?(assignment_submission)
    end

    test "return false if assignment's due date is passed", %{
      lecturer: lecturer,
      student: student,
      module: module
    } do
      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      insert(:modules_users, user: student, module: module, role: :student)

      assignment =
        insert(:assignment,
          module: module,
          due_date: DateTime.utc_now() |> DateTime.add(-1, :day)
        )

      assignment_submission =
        insert(:assignment_submission, assignment: assignment, user: student)

      assert false == Handin.Assignments.submission_allowed?(assignment_submission)
    end
  end

  describe "total marks" do
    setup do
      assignment = insert(:assignment, total_marks: 100, enable_total_marks: true)
      {:ok, assignment: assignment}
    end

    test "create assignment_test with valid points", %{assignment: assignment} do
      attrs = %{
        name: "Test 1",
        assignment_id: assignment.id,
        command: "g++ -o main main.cpp",
        expected_output_type: :string,
        expected_output_text: "Hello, World!"
      }

      {:ok, %AssignmentTest{} = test} = Assignments.create_assignment_test(attrs)

      {:ok, test} =
        test
        |> Repo.preload(:assignment)
        |> Assignments.update_assignment_test(%{
          points_on_pass: 10.0,
          points_on_fail: 0.0
        })

      assert test.points_on_pass == 10
      assert test.points_on_fail == 0
    end

    test "create assignment_test with points exceeding total marks", %{assignment: assignment} do
      attrs = %{
        name: "Test 1",
        assignment_id: assignment.id,
        command: "g++ -o main main.cpp",
        expected_output_type: :string,
        expected_output_text: "Hello, World!"
      }

      {:ok, %AssignmentTest{} = test} = Assignments.create_assignment_test(attrs)

      assert {:error, changeset} =
               test
               |> Repo.preload(:assignment)
               |> Assignments.update_assignment_test(%{
                 points_on_pass: 110.0,
                 points_on_fail: 0.0
               })

      assert "Points exceed total marks. Please ensure points on pass assigned do not surpass the total marks." in errors_on(
               changeset
             ).points_on_pass
    end

    test "update assignment_test with negative points", %{assignment: assignment} do
      test =
        insert(:assignment_test, assignment: assignment, points_on_pass: 10, points_on_fail: 0)

      attrs = %{points_on_pass: -5, points_on_fail: -2}

      assert {:ok, %AssignmentTest{} = updated_test} =
               Assignments.update_assignment_test(test, attrs)

      assert updated_test.points_on_pass == -5
      assert updated_test.points_on_fail == -2
    end

    test "create_assignment_test with points_on_fail greater than points_on_pass", %{
      assignment: assignment
    } do
      attrs = %{
        name: "Test 1",
        assignment_id: assignment.id,
        command: "g++ -o main main.cpp",
        expected_output_type: :string,
        expected_output_text: "Hello, World!"
      }

      {:ok, %AssignmentTest{} = test} = Assignments.create_assignment_test(attrs)

      attrs = %{points_on_pass: 10, points_on_fail: 20}

      assert {:ok, %AssignmentTest{} = updated_test} =
               test
               |> Repo.preload(:assignment)
               |> Assignments.update_assignment_test(attrs)

      assert updated_test.points_on_pass == 10
      assert updated_test.points_on_fail == 20
    end
  end
end
