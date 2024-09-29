defmodule Handin.AssignmentsTest do
  use Handin.DataCase
  import Handin.Factory

  describe "submission_allowed?" do
    test "return true if custom date is set but cut off is not enabled" do
      lecturer = insert(:lecturer)
      student = insert(:student)
      module = insert(:module)

      lecturer_module_user =
        insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      student_module_user = insert(:modules_users, user: student, module: module, role: :student)

      assignment =
        insert(:assignment, module: module, due_date: DateTime.utc_now() |> DateTime.add(1, :day))

      custom_assignment_date =
        insert(:custom_assignment_date, assignment: assignment, user: student)

      assignment_submission =
        insert(:assignment_submission, assignment: assignment, user: student)

      assert true == Handin.Assignments.submission_allowed?(assignment_submission)
    end

    test "return true if custom date is set and cut off is enabled" do
      lecturer = insert(:lecturer)
      student = insert(:student)
      module = insert(:module)

      lecturer_module_user =
        insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      student_module_user = insert(:modules_users, user: student, module: module, role: :student)

      assignment =
        insert(:assignment, module: module, due_date: DateTime.utc_now() |> DateTime.add(1, :day))

      custom_assignment_date =
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

    test "return true if assignment cuto off date is set" do
    end

    test "return true if assignment cutoff date is not set but due date is set" do
    end

    test "return false if custom date's cut off date is passed" do
    end

    test "return false if custom date's due date is passed" do
    end

    test "return false if assignment's cut off date is passed" do
    end

    test "return false if assignment's due date is passed" do
    end
  end
end
