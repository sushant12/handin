defmodule HandinWeb.StudentEnrollmentControllerTest do
  use HandinWeb.ConnCase, async: true

  import HandinWeb.Factory
  import Handin.AccountsFixtures

  setup do
    %{user: user_fixture(), module: insert(:module)}
  end

  describe "GET /module/cs:module_id/register" do
    test "redirected to login page if student not logged in", %{conn: conn, module: module} do
      conn =
        conn
        |> get(~p"/module/cs#{Integer.to_string(module.id)}/register")

      %{"error" => error} = get_flash(conn)

      assert error =~ "You must log in to access this page."
    end

    test "confirmation page is rendered", %{conn: conn, user: user, module: module} do
      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/module/cs#{Integer.to_string(module.id)}/register")

      response = html_response(conn, 200)
      assert response =~ "<h3>Join Module: <b>#{module.name}</b></h3>"
      assert response =~ "Join Module?"
    end
  end

  describe "POST /module/cs:module_id/register" do
    test "Student is enrolled in module", %{conn: conn, user: user, module: module} do
      conn =
        conn
        |> log_in_user(user)
        |> post(~p"/module/cs#{Integer.to_string(module.id)}/register")

      %{"info" => info} = get_flash(conn)
      assert info =~ "Joined module successfully"
    end
  end
end
