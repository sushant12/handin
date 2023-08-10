defmodule HandinWeb.Factory do
  alias Handin.Repo
  alias Handin.ProgrammingLanguages.ProgrammingLanguage
  alias Handin.Assignments.Assignment
  alias Handin.Accounts.User
  alias Handin.Modules.Module
  alias Handin.Universities.University

  defp valid_user_password, do: "hello world!"
  @now NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  @unique_num System.unique_integer()

  def build(:admin) do
    %User{
      email: "admin@admin.com",
      hashed_password: Bcrypt.hash_pwd_salt("admin"),
      confirmed_at: @now,
      role: "admin"
    }
  end

  def build(:user_unconfirmed) do
    %User{
      email: "user#{@unique_num}@studentmail.ul.ie",
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      role: "student"
    }
  end

  def build(:module) do
    %Module{
      name: "M#{@unique_num}",
      code: "CS#{@unique_num}"
    }
  end

  def build(:lecturer) do
    %User{
      email: "lecturer#{@unique_num}@studentmail.ul.ie",
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      confirmed_at: @now,
      role: "lecturer"
    }
  end

  def build(:student_unconfirmed) do
    %User{
      email: "student#{@unique_num}@studentmail.ul.ie",
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      role: "student"
    }
  end

  def build(:student) do
    %User{
      email: "student#{@unique_num}@studentmail.ul.ie",
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      confirmed_at: @now,
      role: "student"
    }
  end

  def build(:university) do
    %University{
      name: "U#{@unique_num}",
      student_email_regex: "^\\d+@studentmail.ul.ie$"
    }
  end

  def build(:programming_language) do
    %ProgrammingLanguage{
      name: "language#{@unique_num}",
      docker_file_url: "some url"
    }
  end

  def build(:assignment) do
    %Assignment{
      name: "some name",
      max_attempts: 42,
      total_marks: 42,
      start_date: ~U[2023-07-22 12:41:00Z],
      due_date: ~U[2023-07-22 12:41:00Z],
      cutoff_date: ~U[2023-07-22 12:41:00Z],
      penalty_per_day: 120.5
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
