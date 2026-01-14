defmodule HandinWeb.AssignmentTestOutputController do
  use HandinWeb, :controller
  alias Handin.Assignments
  alias HandinWeb.UploadHelper

  def upload_file(conn, %{
        "assignment_id" => _assignment_id,
        "assignment_test_id" => assignment_test_id,
        "file" => file,
        "submission_id" => submission_id
      }) do
    case Base.decode64(file) do
      {:ok, decoded_file} ->
        attrs = %{
          assignment_test_id: assignment_test_id,
          assignment_submission_id: submission_id
        }

        temp_file_path = "/tmp/#{submission_id}.tmp"

        File.write!(temp_file_path, decoded_file)

        case Assignments.create_assignment_test_output_file(attrs) do
          {:ok, assignment_test_output_file} ->
            {:ok, format} = UploadHelper.get_file_format(decoded_file)
            filename = "#{submission_id}.#{format}" |> IO.inspect()

            Assignments.upload_assignment_test_output_file(assignment_test_output_file, %{
              file: %Plug.Upload{
                filename: filename,
                path: temp_file_path,
                content_type: MIME.from_path(filename)
              }
            })

            File.rm!(temp_file_path)

            conn
            |> put_status(:created)
            |> json(%{message: "File uploaded successfully"})

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: changeset})
        end

      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid base64 file"})
    end
  end

  # WIP: need to consider for lecturer
  # because lecturer does not have submission
  def upload_file(conn, %{
        "assignment_id" => _assignment_id,
        "assignment_test_id" => assignment_test_id,
        "file" => file
      }) do
    case Base.decode64(file) do
      {:ok, decoded_file} ->
        attrs = %{
          assignment_test_id: assignment_test_id
        }

        temp_file_path = "/tmp/#{assignment_test_id}.tmp"

        File.write!(temp_file_path, decoded_file)

        case Assignments.create_assignment_test_output_file(attrs) do
          {:ok, assignment_test_output_file} ->
            {:ok, format} = UploadHelper.get_file_format(decoded_file)
            filename = "default.#{format}" |> IO.inspect()

            Assignments.upload_assignment_test_output_file(assignment_test_output_file, %{
              file: %Plug.Upload{
                filename: filename,
                path: temp_file_path,
                content_type: MIME.from_path(filename)
              }
            })

            File.rm!(temp_file_path)

            conn
            |> put_status(:created)
            |> json(%{message: "File uploaded successfully"})

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: changeset})
        end

      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid base64 file"})
    end
  end
end
