defmodule HandinWeb.Admin.AddUserController do
  use HandinWeb, :controller
  alias Handin.Accounts

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"email" => _email, "role" => _role} = user_params) do
    with {:ok, user} <- Accounts.register_user_by_admin(user_params) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &Routes.user_reset_password_url(conn, :edit, &1)
      )

      conn
      |> put_session(:user_return_to, "/admin")
      |> redirect(to: Routes.admin_page_path(conn, :index))
    else
      {:error, %{errors: _errors} = changeset} ->
        render(conn, "new.html", error_message: "Email already taken")
    end
  end
end
