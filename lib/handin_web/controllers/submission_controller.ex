defmodule HandinWeb.SubmissionController do
  use HandinWeb, :controller

  alias Handin.{AssignmentSubmissions, Assignments, Repo}

  def download(conn, %{"assignment_id" => assignment_id, "id" => _module_id}) do
    assignment = Assignments.get_assignment!(assignment_id)

    conn =
      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"#{assignment.name}.csv\"")
      |> send_chunked(200)

    Repo.transaction(fn ->
      student_grades = AssignmentSubmissions.get_student_grades_for_assignment(assignment_id)

      test_headers =
        List.first(student_grades)
        |> Map.keys()
        |> Enum.filter(&(&1 not in ["email", "attempt_marks", "total"]))

      headers = ["email", "attempt_marks"] ++ test_headers ++ ["total"]

      rows = NimbleCSV.RFC4180.dump_to_iodata([headers])
      {:ok, _} = chunk(conn, rows)

      rows =
        AssignmentSubmissions.get_student_grades_for_assignment(assignment_id)
        |> Enum.map(fn student_grade ->
          Enum.map(headers, fn header -> student_grade[header] end)
        end)
        |> NimbleCSV.RFC4180.dump_to_iodata()

      {:ok, _conn} = chunk(conn, rows)
    end)

    conn
  end
end
