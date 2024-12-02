defmodule Handin.AssignmentSubmissions do
  import Ecto.Query, warn: false

  use Torch.Pagination,
    repo: Handin.Repo,
    model: Handin.AssignmentSubmissions.AssignmentSubmission,
    name: :assignment_submissions

  alias Handin.Assignments.Assignment
  alias Handin.{Repo, DisplayHelper}
  alias Handin.AssignmentSubmissions.AssignmentSubmission
  alias Handin.AssignmentSubmissions.AssignmentSubmissionFile

  def get_assignment_submission_file!(assignment_submission_id) do
    Repo.get!(AssignmentSubmissionFile, assignment_submission_id)
    |> Repo.preload(assignment_submission: [:user, :assignment])
  end

  def get_student_grades_for_assignment(assignment_id) do
    assignment = fetch_assignment_with_preloads(assignment_id)

    assignment.module.users
    |> Enum.filter(&(&1.role == :student))
    |> Enum.map(&calculate_student_grade(&1, assignment))
  end

  defp fetch_assignment_with_preloads(assignment_id) do
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

  defp calculate_student_grade(user, assignment) do
    build = get_latest_build(assignment.builds, user.id)
    assignment_submission = get_assignment_submission(assignment.assignment_submissions, user.id)

    attempt_marks = calculate_attempt_marks(build, assignment.attempt_marks)
    test_result_marks = calculate_test_result_marks(build, assignment.assignment_tests)
    total_points = get_total_points(assignment_submission)

    Map.merge(test_result_marks, %{
      "full_name" => DisplayHelper.get_full_name(user),
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

  defp get_assignment_submission(submissions, user_id) do
    Enum.find(submissions, &(&1.user_id == user_id))
  end

  defp calculate_attempt_marks(nil, _attempt_marks), do: 0

  defp calculate_attempt_marks(build, attempt_marks) do
    if build.run_script_result && build.run_script_result.state == :pass,
      do: attempt_marks,
      else: 0
  end

  defp calculate_test_result_marks(nil, assignment_tests) do
    Enum.reduce(assignment_tests, %{}, &Map.put(&2, &1.name, 0))
  end

  defp calculate_test_result_marks(build, _assignment_tests) do
    Enum.reduce(build.test_results, %{}, fn test_result, acc ->
      test_marks =
        if test_result.state == :pass, do: test_result.assignment_test.points_on_pass, else: 0

      Map.put(acc, test_result.assignment_test.name, test_marks)
    end)
  end

  defp get_total_points(nil), do: 0
  defp get_total_points(assignment_submission), do: assignment_submission.total_points

  def change_assignment_submission(assignment_submission) do
    AssignmentSubmission.changeset(assignment_submission, %{})
  end

  def create_assignment_submission(attrs) do
    %AssignmentSubmission{}
    |> AssignmentSubmission.changeset(attrs)
    |> Repo.insert()
  end

  def get_assignment_submission!(id),
    do: Repo.get!(AssignmentSubmission, id) |> Repo.preload([:user, :assignment])

  def update_assignment_submission(assignment_submission, attrs) do
    assignment_submission
    |> AssignmentSubmission.changeset(attrs)
    |> Repo.update()
  end

  def delete_assignment_submission(assignment_submission) do
    Repo.delete(assignment_submission)
  end

  def delete_assignment_submission!(id), do: Repo.get!(AssignmentSubmission, id) |> Repo.delete()
end
