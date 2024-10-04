defmodule Handin.AssignmentsTest do
  use Handin.DataCase
  import Handin.Factory

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
end
