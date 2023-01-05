defmodule HandinWeb.Factory do
  use ExMachina.Ecto, repo: Handin.Repo

  def admin_factory do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    %Handin.Accounts.User{
      email: "admin@admin.com",
      hashed_password: Bcrypt.hash_pwd_salt("admin"),
      confirmed_at: now,
      role: "admin"
    }
  end
end
