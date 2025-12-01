defmodule HandinWeb.AccessControlTest do
  use HandinWeb.ConnCase
  import Phoenix.LiveViewTest
  import Handin.Factory

  alias Handin.{Accounts, Repo}
  alias Handin.Accounts.UserToken

  describe "lecturer access control" do
    setup do
      lecturer = insert(:lecturer)
      module = insert(:module)
      assignment = insert(:assignment, module: module)

      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      token = Accounts.generate_user_session_token(lecturer)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      %{lecturer: lecturer, module: module, assignment: assignment, conn: conn}
    end

    test "lecturer can access create module page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/modules/new")
      assert html =~ "New Module" or html =~ "module" or html != ""
    end

    test "lecturer can access archived modules page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/modules/archived")
      assert html != ""
    end

    test "lecturer can access edit module page", %{conn: conn, module: module} do
      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/edit")
      assert html != ""
    end

    test "lecturer can access create assignment page", %{conn: conn, module: module} do
      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/assignments/new")
      assert html != ""
    end

    test "lecturer can access edit assignment page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/edit")
      assert html != ""
    end

    test "lecturer can access assignment environment page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      {:ok, _view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/environment")

      assert html =~ "Environment"
    end

    test "lecturer can access add helper files page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      {:ok, _view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/add_helper_files")

      assert html != ""
    end

    test "lecturer can access add solution files page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      {:ok, _view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/add_solution_files")

      assert html != ""
    end

    test "lecturer can access assignment tests page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      {:ok, _view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/tests")

      assert html != ""
    end

    test "lecturer can access assignment submissions page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      {:ok, _view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/submissions")

      assert html != ""
    end

    test "lecturer can access assignment settings page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      {:ok, _view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/settings")

      assert html != ""
    end

    test "lecturer can access add student page", %{conn: conn, module: module} do
      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/students/new")
      assert html != ""
    end

    test "lecturer can access bulk add students page", %{conn: conn, module: module} do
      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/students/bulk_add")
      assert html != ""
    end

    test "lecturer can access add teaching assistant page", %{conn: conn, module: module} do
      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/teaching_assistants/new")
      assert html != ""
    end
  end

  describe "student access control - cannot access lecturer routes" do
    setup do
      student = insert(:student)
      module = insert(:module)
      assignment = insert(:assignment, module: module)

      insert(:modules_users, user: student, module: module, role: :student)

      token = Accounts.generate_user_session_token(student)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      %{student: student, module: module, assignment: assignment, conn: conn}
    end

    test "student cannot access create module page", %{conn: conn} do
      assert_unauthorized_redirect(conn, ~p"/modules/new", ~p"/")
    end

    test "student cannot access archived modules page", %{conn: conn} do
      assert_unauthorized_redirect(conn, ~p"/modules/archived", ~p"/")
    end

    test "student cannot access edit module page", %{conn: conn, module: module} do
      assert_unauthorized_redirect(conn, ~p"/modules/#{module.id}/edit", ~p"/")
    end

    test "student cannot access create assignment page", %{conn: conn, module: module} do
      assert_unauthorized_redirect(conn, ~p"/modules/#{module.id}/assignments/new", ~p"/")
    end

    test "student cannot access edit assignment page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      assert_unauthorized_redirect(
        conn,
        ~p"/modules/#{module.id}/assignments/#{assignment.id}/edit",
        ~p"/"
      )
    end

    test "student cannot access assignment environment page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      assert_redirect(
        conn,
        ~p"/modules/#{module.id}/assignments/#{assignment.id}/environment",
        ~p"/"
      )
    end

    test "student cannot access add helper files page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      assert_redirect(
        conn,
        ~p"/modules/#{module.id}/assignments/#{assignment.id}/add_helper_files",
        ~p"/"
      )
    end

    test "student cannot access add solution files page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      assert_redirect(
        conn,
        ~p"/modules/#{module.id}/assignments/#{assignment.id}/add_solution_files",
        ~p"/"
      )
    end

    test "student cannot access assignment tests page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      assert_unauthorized_redirect(
        conn,
        ~p"/modules/#{module.id}/assignments/#{assignment.id}/tests",
        ~p"/"
      )
    end

    test "student cannot access assignment submissions page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      assert_redirect(
        conn,
        ~p"/modules/#{module.id}/assignments/#{assignment.id}/submissions",
        ~p"/"
      )
    end

    test "student cannot access assignment settings page", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      assert_redirect(
        conn,
        ~p"/modules/#{module.id}/assignments/#{assignment.id}/settings",
        ~p"/"
      )
    end

    test "student cannot access add student page", %{conn: conn, module: module} do
      assert_unauthorized_redirect(conn, ~p"/modules/#{module.id}/students/new", ~p"/")
    end

    test "student cannot access bulk add students page", %{conn: conn, module: module} do
      assert_unauthorized_redirect(conn, ~p"/modules/#{module.id}/students/bulk_add", ~p"/")
    end

    test "student cannot access add teaching assistant page", %{conn: conn, module: module} do
      assert_unauthorized_redirect(conn, ~p"/modules/#{module.id}/teaching_assistants/new", ~p"/")
    end
  end

  describe "common routes - accessible by both lecturers and students" do
    test "lecturer can access modules list" do
      lecturer = insert(:lecturer)
      token = Accounts.generate_user_session_token(lecturer)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      {:ok, _view, html} = live(conn, ~p"/modules")
      assert html != ""
    end

    test "student can access modules list" do
      student = insert(:student)
      token = Accounts.generate_user_session_token(student)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      {:ok, _view, html} = live(conn, ~p"/modules")
      assert html != ""
    end

    test "lecturer can access module assignments" do
      lecturer = insert(:lecturer)
      module = insert(:module)
      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      token = Accounts.generate_user_session_token(lecturer)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/assignments")
      assert html != ""
    end

    test "student can access module assignments" do
      student = insert(:student)
      module = insert(:module)
      insert(:modules_users, user: student, module: module, role: :student)

      token = Accounts.generate_user_session_token(student)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/assignments")
      assert html != ""
    end

    test "lecturer can access assignment details" do
      lecturer = insert(:lecturer)
      module = insert(:module)
      assignment = insert(:assignment, module: module)
      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      token = Accounts.generate_user_session_token(lecturer)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      {:ok, _view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/details")

      assert html != ""
    end

    test "student can access assignment details" do
      student = insert(:student)
      module = insert(:module)
      assignment = insert(:assignment, module: module)
      insert(:modules_users, user: student, module: module, role: :student)

      token = Accounts.generate_user_session_token(student)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      {:ok, _view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/details")

      assert html != ""
    end

    test "lecturer can access students list" do
      lecturer = insert(:lecturer)
      module = insert(:module)
      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      token = Accounts.generate_user_session_token(lecturer)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/students")
      assert html != ""
    end

    test "student can access students list" do
      student = insert(:student)
      module = insert(:module)
      insert(:modules_users, user: student, module: module, role: :student)

      token = Accounts.generate_user_session_token(student)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/students")
      assert html != ""
    end

    test "lecturer can access teaching assistants list" do
      lecturer = insert(:lecturer)
      module = insert(:module)
      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      token = Accounts.generate_user_session_token(lecturer)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/teaching_assistants")
      assert html != ""
    end

    test "student can access teaching assistants list" do
      student = insert(:student)
      module = insert(:module)
      insert(:modules_users, user: student, module: module, role: :student)

      token = Accounts.generate_user_session_token(student)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/teaching_assistants")
      assert html != ""
    end
  end

  describe "action restrictions" do
    setup do
      lecturer = insert(:lecturer)
      student = insert(:student)
      module = insert(:module)
      assignment = insert(:assignment, module: module)

      insert(:modules_users, user: lecturer, module: module, role: :lecturer)
      insert(:modules_users, user: student, module: module, role: :student)

      lecturer_token = Accounts.generate_user_session_token(lecturer)
      student_token = Accounts.generate_user_session_token(student)

      lecturer_conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, lecturer_token)

      student_conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, student_token)

      %{
        lecturer: lecturer,
        student: student,
        module: module,
        assignment: assignment,
        lecturer_conn: lecturer_conn,
        student_conn: student_conn
      }
    end

    test "lecturer can assign teaching assistant", %{
      lecturer_conn: conn,
      module: module
    } do
      ta_attrs = %{
        email: "ta@ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      {:ok, ta_user} = Accounts.register_user(ta_attrs)

      {encoded_token, user_token} =
        UserToken.build_email_token(ta_user, "confirm")

      Repo.insert!(user_token)
      {:ok, _confirmed_ta} = Accounts.confirm_user(encoded_token)

      {:ok, view, _html} = live(conn, ~p"/modules/#{module.id}/teaching_assistants/new")

      view
      |> form("#teaching-assistant-form", user: %{email: ta_user.email})
      |> render_submit()

      module_user =
        Repo.get_by(Handin.Modules.ModulesUsers,
          user_id: ta_user.id,
          module_id: module.id,
          role: :teaching_assistant
        )

      assert module_user != nil
    end

    test "student cannot assign teaching assistant", %{
      student_conn: conn,
      module: module
    } do
      assert_unauthorized_redirect(conn, ~p"/modules/#{module.id}/teaching_assistants/new", ~p"/")
    end

    test "lecturer can create assignment", %{
      lecturer_conn: conn,
      module: module
    } do
      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/assignments/new")
      assert html != ""
    end

    test "student cannot create assignment", %{
      student_conn: conn,
      module: module
    } do
      assert_unauthorized_redirect(conn, ~p"/modules/#{module.id}/assignments/new", ~p"/")
    end

    test "lecturer can update environment", %{
      lecturer_conn: conn,
      module: module,
      assignment: assignment
    } do
      {:ok, _view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/environment")

      assert html =~ "Environment"
    end

    test "student cannot update environment", %{
      student_conn: conn,
      module: module,
      assignment: assignment
    } do
      assert_redirect(
        conn,
        ~p"/modules/#{module.id}/assignments/#{assignment.id}/environment",
        ~p"/"
      )
    end

    test "lecturer can add students to module", %{
      lecturer_conn: conn,
      module: module
    } do
      {:ok, _view, html} = live(conn, ~p"/modules/#{module.id}/students/new")
      assert html != ""
    end

    test "student cannot add students to module", %{
      student_conn: conn,
      module: module
    } do
      assert_unauthorized_redirect(conn, ~p"/modules/#{module.id}/students/new", ~p"/")
    end
  end

  describe "teaching assistant access control" do
    setup do
      ta = insert(:student)
      module = insert(:module)
      assignment = insert(:assignment, module: module)

      insert(:modules_users, user: ta, module: module, role: :teaching_assistant)

      token = Accounts.generate_user_session_token(ta)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      %{ta: ta, module: module, assignment: assignment, conn: conn}
    end

    test "teaching assistant can access assignment submissions", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      {:ok, _view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/submissions")

      assert html != ""
    end

    test "teaching assistant can access assignment tests", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      {:ok, _view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/tests")

      assert html != ""
    end

    test "teaching assistant can access assignment environment", %{
      conn: conn,
      module: module,
      assignment: assignment
    } do
      {:ok, _view, html} =
        live(conn, ~p"/modules/#{module.id}/assignments/#{assignment.id}/environment")

      assert html =~ "Environment"
    end

    test "teaching assistant cannot create new module", %{conn: conn} do
      assert_unauthorized_redirect(conn, ~p"/modules/new", ~p"/")
    end

    test "teaching assistant cannot archive module", %{conn: conn, module: module} do
      assert_unauthorized_redirect(conn, ~p"/modules/#{module.id}/archive", ~p"/")
    end
  end

  defp assert_unauthorized_redirect(conn, path, expected_redirect_path) do
    result = live(conn, path)

    case result do
      {:error, {:redirect, %{to: redirect_path}}} ->
        assert redirect_path == expected_redirect_path

      {:error, {:live_redirect, %{to: redirect_path}}} ->
        assert redirect_path == expected_redirect_path

      {:ok, view, _html} ->
        html = render(view)
        assert html =~ "not authorized" or html =~ "You are not authorized"

      other ->
        flunk("Expected redirect to #{expected_redirect_path}, got: #{inspect(other)}")
    end
  end
end
