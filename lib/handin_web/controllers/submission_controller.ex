defmodule HandinWeb.SubmissionController do
  use HandinWeb, :controller

  alias Handin.{AssignmentSubmissions, Assignments, Repo}

  def download(conn, %{"assignment_id" => assignment_id, "id" => _module_id}) do
    assignment = Assignments.get_assignment!(assignment_id)
    conn = prepare_conn_for_csv_download(conn, assignment.name)

    Repo.transaction(fn ->
      student_grades =
        AssignmentSubmissions.get_student_grades_for_assignment(assignment_id)

      headers = generate_headers(student_grades)

      send_csv_data(conn, headers, student_grades)
    end)

    conn
  end

  defp prepare_conn_for_csv_download(conn, filename) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}.csv\"")
    |> send_chunked(200)
  end

  defp generate_headers(student_grades) do
    test_headers =
      List.first(student_grades)
      |> Map.keys()
      |> Enum.filter(&(&1 not in ["full_name", "id", "attempt_marks", "total"]))

    ["full_name", "id", "attempt_marks"] ++ test_headers ++ ["total"]
  end

  defp send_csv_data(conn, headers, student_grades) do
    header_row = NimbleCSV.RFC4180.dump_to_iodata([headers])
    {:ok, _} = chunk(conn, header_row)

    rows =
      student_grades
      |> Enum.map(fn student_grade ->
        Enum.map(headers, fn header -> student_grade[header] end)
      end)
      |> NimbleCSV.RFC4180.dump_to_iodata()

    {:ok, _conn} = chunk(conn, rows)
  end
end
