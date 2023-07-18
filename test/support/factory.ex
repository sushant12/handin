defmodule HandinWeb.Factory do
  use ExMachina.Ecto, repo: Handin.Repo
  alias Handin.Accounts.User
  alias Handin.Modules.Module

  defp valid_user_password, do: "hello world!"
  @now NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

  def admin_factory do
    %User{
      email: "admin@admin.com",
      hashed_password: Bcrypt.hash_pwd_salt("admin"),
      confirmed_at: @now,
      role: "admin"
    }
  end

  def module_factory do
    %Module{
      name: sequence(:name, &"M#{&1}")
    }
  end

  def teacher_factory do
    %User{
      email: sequence(:email, &"teacher#{&1}@studentmail.ul.ie"),
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      confirmed_at: @now,
      role: "teacher"
    }
  end
end
