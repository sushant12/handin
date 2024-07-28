defmodule HandinWeb.SubmissionController do
  use HandinWeb, :controller

  alias Handin.{AssignmentSubmissions, Assignments, Repo}

  def download(conn, %{"assignment_id" => assignment_id, "id" => _module_id}) do
    assignment = Assignments.get_assignment!(assignment_id)
    filename = "#{assignment.name}.csv"

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
    |> send_chunked(200)
    |> stream_csv_data(assignment_id)
  end

  defp stream_csv_data(conn, assignment_id) do
    Repo.transaction(fn ->
      student_grades = AssignmentSubmissions.get_student_grades_for_assignment(assignment_id)
      headers = get_csv_headers(student_grades)

      stream_csv_headers(conn, headers)
      stream_csv_rows(conn, student_grades, headers)
    end)

    conn
  end

  defp get_csv_headers(student_grades) do
    first_grade = List.first(student_grades)
    test_headers = Map.keys(first_grade) -- ["email", "attempt_marks", "total"]
    ["email", "attempt_marks"] ++ test_headers ++ ["total"]
  end

  defp stream_csv_headers(conn, headers) do
    rows = NimbleCSV.RFC4180.dump_to_iodata([headers])
    {:ok, _} = chunk(conn, rows)
  end

  defp stream_csv_rows(conn, student_grades, headers) do
    rows = student_grades
    |> Enum.map(fn student_grade ->
      Enum.map(headers, &Map.get(student_grade, &1, ""))
    end)
    |> NimbleCSV.RFC4180.dump_to_iodata()

    {:ok, _conn} = chunk(conn, rows)
  end
end
