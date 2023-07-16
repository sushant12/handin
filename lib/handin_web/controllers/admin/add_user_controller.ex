defmodule HandinWeb.Admin.AddUserController do
  use HandinWeb, :controller
  alias Handin.Accounts

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"email" => _email, "role" => _role} = user_params) do
    with {:ok, user} <- Accounts.register_user_by_admin(user_params) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &~p"/users/reset_password/#{&1}"
      )

      conn
      |> put_session(:user_return_to, "/admin")
      |> redirect(to: ~p"/admin")
    else
      {:error, %{errors: _errors} = _changeset} ->
        render(conn, :new, error_message: "Email already taken")
    end
  end
end
