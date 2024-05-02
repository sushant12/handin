defmodule Handin.AssignmentSubmissions do
  import Ecto.Query, warn: false

  alias Handin.Assignments.Build
  alias Handin.Assignments.Assignment
  alias Handin.Repo
  alias Handin.AssignmentSubmission.AssignmentSubmission
  alias Handin.AssignmentSubmission.AssignmentSubmissionFile

  def get_assignment_submission_file!(assignment_submission_id) do
    Repo.get!(AssignmentSubmissionFile, assignment_submission_id)
    |> Repo.preload(assignment_submission: [:user, :assignment])
  end

  def get_student_grades_for_assignment(assignment_id) do
    assignment =
      Assignment
      |> where([a], a.id == ^assignment_id)
      |> Repo.one()
      |> Repo.preload([:assignment_tests, module: [:users]])

    assignment.module.users
    |> Enum.filter(fn user -> user.role == :student end)
    |> Enum.map(fn user ->
      build =
        Build
        |> where([b], b.user_id == ^user.id and b.assignment_id == ^assignment_id)
        |> order_by([b], desc: b.inserted_at)
        |> limit(1)
        |> Repo.one()
        |> Repo.preload([:run_script_result, test_results: [:assignment_test]])

      assignment_submission =
        AssignmentSubmission
        |> where([as], as.assignment_id == ^assignment_id and as.user_id == ^user.id)
        |> Repo.one()

      attempt_marks =
        if not is_nil(build) && build.run_script_result.state == :pass do
          assignment.attempt_marks
        else
          0
        end

      test_result_marks =
        if attempt_marks == 0 do
          assignment.assignment_tests
          |> Enum.reduce(%{}, fn assignment_test, acc ->
            Map.merge(acc, %{assignment_test.command => 0})
          end)
        else
          build.test_results
          |> Enum.reduce(%{}, fn test_result, acc ->
            test_marks =
              if test_result.state == :pass do
                assignment.attempt_marks
              else
                0
              end

            Map.merge(acc, %{test_result.assignment_test.command => test_marks})
          end)
        end

      total_points =
        if(is_nil(assignment_submission)) do
          0
        else
          assignment_submission.total_points
        end

      Map.merge(test_result_marks, %{
        "email" => user.email,
        "attempt_marks" => attempt_marks,
        "total" => "#{total_points}/#{assignment.total_marks}"
      })
    end)
  end
end
