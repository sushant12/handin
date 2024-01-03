defmodule HandinWeb.AdminSessionControllerTest do
  use HandinWeb.ConnCase, async: true

  describe "POST /admin/log_in" do
    test "log the admin in", %{conn: conn} do
      conn =
        conn
        |> post(~p"/admin/log_in", %{
          "user" => %{
            "email" => "admin@admin.com",
            "password" => "admin"
          }
        })

      response = html_response(conn, 302)
      assert response =~ "You are being <a href=\"/admin\">redirected</a>."
      assert redirected_to(conn) == "/admin"
    end
  end
end
