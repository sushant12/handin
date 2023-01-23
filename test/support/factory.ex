defmodule HandinWeb.Factory do
  use ExMachina.Ecto, repo: Handin.Repo
  alias Handin.Accounts.User
  alias Handin.Courses.Course
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

  def course_admin_factory do
    %User{
      email: sequence(:email, &"course admin#{&1}@studentmail.ul.ie"),
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      confirmed_at: @now,
      role: "course_admin"
    }
  end

  def course_factory do
    %Course{
      name: sequence(:name, &"course name #{&1}"),
      code: sequence(:code, fn x -> x end)
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
