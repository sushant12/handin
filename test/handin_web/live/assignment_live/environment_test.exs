defmodule HandinWeb.AssignmentLive.EnvironmentTest do
  use HandinWeb.ConnCase
  import Phoenix.LiveViewTest
  import Handin.Factory

  alias Handin.{Accounts, Assignments, ProgrammingLanguages}

  describe "creating and updating environment" do
    setup do
      lecturer = insert(:lecturer)
      module = insert(:module)
      assignment = insert(:assignment, module: module)

      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      {:ok, programming_language} =
        ProgrammingLanguages.create_programming_language(%{
          name: "Python",
          docker_file_url: "python:latest"
        })

      token = Accounts.generate_user_session_token(lecturer)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      %{
        lecturer: lecturer,
        module: module,
        assignment: assignment,
        programming_language: programming_language,
        conn: conn
      }
    end

    test "lecturer can create an environment by selecting programming language", %{
      conn: conn,
      module: module,
      assignment: assignment,
      programming_language: programming_language
    } do
      {:ok, view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/environment")

      assert html =~ "Environment"
      assert html =~ "Language"

      view
      |> form("form", assignment: %{programming_language_id: programming_language.id})
      |> render_submit()

      {:ok, updated_assignment} = Assignments.get_assignment(assignment.id, module.id)
      assert updated_assignment.programming_language_id == programming_language.id
    end

    test "lecturer can update environment with run script", %{
      conn: conn,
      module: module,
      assignment: assignment,
      programming_language: programming_language
    } do
      run_script = "g++ -o main main.cpp && ./main"

      # Update assignment with run script first (simulating Monaco editor update)
      {:ok, assignment_with_script} =
        Assignments.update_assignment(assignment, %{
          "run_script" => run_script
        })

      {:ok, view, _html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment_with_script.id}/environment")

      # Submit form with programming language
      view
      |> form("form", assignment: %{programming_language_id: programming_language.id})
      |> render_submit()

      {:ok, updated_assignment} = Assignments.get_assignment(assignment.id, module.id)
      assert updated_assignment.programming_language_id == programming_language.id
      assert updated_assignment.run_script == run_script
    end

    test "lecturer can update both programming language and run script", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      {:ok, cpp_lang} =
        ProgrammingLanguages.create_programming_language(%{
          name: "C++",
          docker_file_url: "gcc:latest"
        })

      run_script = "make clean && make && ./program"

      # Update assignment with run script first
      {:ok, assignment_with_script} =
        Assignments.update_assignment(assignment, %{
          "run_script" => run_script
        })

      {:ok, view, _html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment_with_script.id}/environment")

      view
      |> form("form", assignment: %{programming_language_id: cpp_lang.id})
      |> render_submit()

      {:ok, final_assignment} = Assignments.get_assignment(assignment.id, module.id)
      assert final_assignment.programming_language_id == cpp_lang.id
      assert final_assignment.run_script == run_script
    end

    test "environment page shows current assignment settings", %{
      conn: conn,
      module: module,
      assignment: assignment,
      programming_language: programming_language
    } do
      run_script = "npm install && npm test"

      {:ok, updated_assignment} =
        Assignments.update_assignment(assignment, %{
          "programming_language_id" => programming_language.id,
          "run_script" => run_script
        })

      {:ok, _view, html} =
        live(
          conn,
          ~p"/modules/#{module.id}/assignments/#{updated_assignment.id}/environment"
        )

      assert html =~ "Environment"
      assert html =~ "Run Script"
      assert html =~ "Test Resource Files"
      assert html =~ "Solution Files"
    end
  end
end
