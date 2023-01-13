defmodule HandinWeb.AddUserControllerTest do
  use HandinWeb.ConnCase, async: true

  import HandinWeb.Factory
  import Handin.AccountsFixtures

  setup do
    %{admin: insert(:admin)}
  end

  describe "GET /admin/add_user" do
    test "renders the add user page", %{conn: conn, admin: admin} do
      conn =
        conn
        |> log_in_user(admin)
        |> get(Routes.admin_add_user_path(conn, :new))

      response = html_response(conn, 200)
      assert response =~ "<h1>Add user</h1>"
    end
  end

  describe "POST /admin/add_user" do
    test "creates admin user", %{conn: conn, admin: admin} do
      email = unique_user_email()

      conn =
        conn
        |> log_in_user(admin)
        |> post(
          Routes.admin_add_user_path(conn, :create, %{
            "email" => email,
            "role" => "admin"
          })
        )

      user = Handin.Repo.get_by(Handin.Accounts.User, email: email)
      assert user.role == "admin"
    end

    test "email already taken error if a user already added", %{conn: conn, admin: admin} do
      email = unique_user_email()

      conn =
        conn
        |> log_in_user(admin)
        |> post(
          Routes.admin_add_user_path(conn, :create, %{
            "email" => email,
            "role" => "course_admin"
          })
        )
        |> post(
          Routes.admin_add_user_path(conn, :create, %{
            "email" => email,
            "role" => "student"
          })
        )

      response = html_response(conn, 200)
      assert response =~ "<p>Email already taken</p>"
    end
  end
end
