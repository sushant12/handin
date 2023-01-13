defmodule HandinWeb.Factory do
  use ExMachina.Ecto, repo: Handin.Repo
  alias Handin.Accounts.User
  alias Handin.Courses.Course

  defp valid_user_password, do: "hello world!"

  def admin_factory do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    %User{
      email: "admin@admin.com",
      hashed_password: Bcrypt.hash_pwd_salt("admin"),
      confirmed_at: now,
      role: "admin"
    }
  end

  def course_admin_factory do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    %User{
      email: sequence(:email, &"#{&1}@studentmail.ul.ie"),
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      confirmed_at: now,
      role: "course_admin"
    }
  end

  def course_factory do
    %Course{
      name: sequence(:name, &"course name #{&1}"),
      code: sequence(:code, fn x -> x end)
    }
  end
end
