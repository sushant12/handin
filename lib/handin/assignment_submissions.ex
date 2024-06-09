defmodule Handin.AssignmentSubmissions do
  import Ecto.Query, warn: false

  alias Handin.Assignments.Assignment
  alias Handin.Repo
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
      |> Repo.preload([
        :assignment_tests,
        :assignment_submissions,
        builds: [:run_script_result, test_results: [:assignment_test]],
        module: [:users]
      ])

    assignment.module.users
    |> Enum.filter(fn user -> user.role == :student end)
    |> Enum.map(fn user ->
      build =
        assignment.builds
        |> Enum.filter(fn build -> build.user_id == user.id end)
        |> case do
          [] -> nil
          builds -> Enum.sort_by(builds, & &1.inserted_at, {:desc, DateTime}) |> List.first()
        end

      assignment_submission =
        if is_nil(build) do
          nil
        else
          assignment.assignment_submissions
          |> Enum.find(fn assingment_submission -> assingment_submission.user_id == user.id end)
        end

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
                test_result.assignment_test.points_on_pass
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
        "total" => total_points
      })
    end)
  end
end
