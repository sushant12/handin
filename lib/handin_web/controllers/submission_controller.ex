defmodule HandinWeb.SubmissionController do
  use HandinWeb, :controller

  alias Handin.{AssignmentSubmissions, Assignments, Repo}
  # alias Handin.{Assignments, Modules, Repo}

  def download(conn, %{"assignment_id" => assignment_id, "id" => _module_id}) do
    assignment = Assignments.get_assignment!(assignment_id)

    # assignment_submissions =
    #   Assignments.get_submissions_for_assignment(assignment_id)

    # students_with_submission =
    #   Enum.map(assignment_submissions, & &1.user)

    # students_without_submission =
    #   Modules.get_students(module_id)
    #   |> Enum.filter(&(&1 not in students_with_submission))

    conn =
      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"#{assignment.name}.csv\"")
      |> send_chunked(200)

    # NOTE: put headers here
    rows = NimbleCSV.RFC4180.dump_to_iodata([["email", "marks"]])
    {:ok, _} = chunk(conn, rows)

    Repo.transaction(fn ->
      # NOTE: need to generate data in [[row1value1, row1value2], [row2value1, row2value2]]
      rows =
        AssignmentSubmissions.get_student_grades_for_assignment(assignment_id)
        |> IO.inspect()
        # (Enum.map(assignment_submissions, fn submission ->
        #    [submission.user.email, "#{submission.total_points}/#{assignment.total_marks}"]
        #  end) ++
        #    Enum.map(students_without_submission, fn student ->
        #      [student.email, "0.0/#{assignment.total_marks}"]
        #    end))
        |> NimbleCSV.RFC4180.dump_to_iodata()

      {:ok, _conn} = chunk(conn, rows)
    end)

    conn
  end
end
