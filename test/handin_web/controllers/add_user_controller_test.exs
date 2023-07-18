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
        |> get(~p"/admin/add_user")

      response = html_response(conn, 200)
      assert response =~ "Add User</h1>"
    end
  end

  describe "POST /admin/add_user" do
    test "creates admin user", %{conn: conn, admin: admin} do
      email = unique_user_email()

      conn =
        conn
        |> log_in_user(admin)
        |> post(
          ~p"/admin/add_user",
          %{
            "email" => email,
            "role" => "admin"
          }
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
          ~p"/admin/add_user",
          %{
            "email" => email,
            "role" => "lecturer"
          }
        )
        |> post(
          ~p"/admin/add_user",
          %{
            "email" => email,
            "role" => "student"
          }
        )

      response = html_response(conn, 200)
      assert response =~ "Email already taken"
    end
  end
end
