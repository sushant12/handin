defmodule HandinWeb.Admin.UserSessionController do
  use HandinWeb, :controller

  alias Handin.Accounts
  alias Handin.Accounts.User
  alias HandinWeb.UserAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    with %User{} = user <- Accounts.get_user_by_email_and_password(email, password),
         "admin" <- Map.get(user, :role) do
      conn
      |> Plug.Conn.put_session(:user_return_to, "/admin")
      |> UserAuth.log_in_user(user, user_params)
    else
      _error -> render(conn, "new.html", error_message: "Invalid email or password")
    end
  end
end
