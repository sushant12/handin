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
    assignment = get_assignment_with_preloads(assignment_id)

    assignment.module.users
    |> Enum.filter(&(&1.role == :student))
    |> Enum.map(&get_student_grade(assignment, &1))
  end

  defp get_assignment_with_preloads(assignment_id) do
    Assignment
    |> where([a], a.id == ^assignment_id)
    |> Repo.one()
    |> Repo.preload([
      :assignment_tests,
      :assignment_submissions,
      builds: [:run_script_result, test_results: [:assignment_test]],
      module: [:users]
    ])
  end

  defp get_student_grade(assignment, user) do
    build = get_latest_build(assignment.builds, user.id)
    assignment_submission = get_assignment_submission(assignment, user.id, build)
    attempt_marks = calculate_attempt_marks(assignment, build)
    test_result_marks = calculate_test_result_marks(assignment, build, attempt_marks)
    total_points = get_total_points(assignment_submission)

    Map.merge(test_result_marks, %{
      "email" => user.email,
      "attempt_marks" => attempt_marks,
      "total" => total_points
    })
  end

  defp get_latest_build(builds, user_id) do
    builds
    |> Enum.filter(&(&1.user_id == user_id))
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
    |> List.first()
  end

  defp get_assignment_submission(assignment, user_id, build) do
    if is_nil(build), do: nil, else: Enum.find(assignment.assignment_submissions, &(&1.user_id == user_id))
  end

  defp calculate_attempt_marks(assignment, build) do
    if not is_nil(build) && build.run_script_result.state == :pass, do: assignment.attempt_marks, else: 0
  end

  defp calculate_test_result_marks(assignment, build, attempt_marks) do
    if attempt_marks == 0 do
      zero_marks_map(assignment.assignment_tests)
    else
      calculate_non_zero_test_marks(build.test_results)
    end
  end

  defp zero_marks_map(assignment_tests) do
    Enum.reduce(assignment_tests, %{}, &Map.put(&2, &1.command, 0))
  end

  defp calculate_non_zero_test_marks(test_results) do
    Enum.reduce(test_results, %{}, fn test_result, acc ->
      test_marks = if test_result.state == :pass, do: test_result.assignment_test.points_on_pass, else: 0
      Map.put(acc, test_result.assignment_test.command, test_marks)
    end)
  end

  defp get_total_points(assignment_submission) do
    if is_nil(assignment_submission), do: 0, else: assignment_submission.total_points
  end
end
