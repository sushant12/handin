defmodule Handin.Factory do
  use ExMachina.Ecto, repo: Handin.Repo

  alias Handin.Accounts.User
  alias Handin.Modules.Module
  alias Handin.Modules.ModulesUsers
  alias Handin.Assignments.Assignment
  alias Handin.AssignmentSubmissions.AssignmentSubmission
  alias Handin.Assignments.CustomAssignmentDate

  def student_factory do
    %User{
      hashed_password: Bcrypt.hash_pwd_salt("123456"),
      email: "123@studentmail.ul.ie",
      role: :student,
      confirmed_at: DateTime.utc_now()
    }
  end

  def admin_factory do
    %User{
      hashed_password: Bcrypt.hash_pwd_salt("123456"),
      email: "admin@example.com",
      role: :admin,
      confirmed_at: DateTime.utc_now()
    }
  end

  def lecturer_factory do
    %User{
      hashed_password: Bcrypt.hash_pwd_salt("123456"),
      email: "sush@ul.ie",
      role: :lecturer,
      confirmed_at: DateTime.utc_now()
    }
  end

  def module_factory do
    %Module{
      name: "Software Engineering",
      code: "CS4221",
      term: "Fall2024"
    }
  end

  def modules_users_factory do
    %ModulesUsers{
      module: build(:module),
      user: build(:lecturer)
    }
  end

  def assignment_factory do
    %Assignment{
      name: "Assignment 1",
      start_date: DateTime.utc_now(),
      due_date: DateTime.utc_now() |> DateTime.add(5, :day),
      module: build(:module)
    }
  end

  def assignment_submission_factory do
    %AssignmentSubmission{
      assignment: build(:assignment),
      user: build(:student)
    }
  end

  def custom_assignment_date_factory do
    %CustomAssignmentDate{
      start_date: DateTime.utc_now(),
      due_date: DateTime.utc_now() |> DateTime.add(5, :day),
      assignment: build(:assignment),
      user: build(:student)
    }
  end

  def assignment_test_factory do
    %Handin.Assignments.AssignmentTest{
      name: "Test 1",
      points_on_pass: 10,
      points_on_fail: 0,
      assignment: build(:assignment),
      command: "g++ -o main main.cpp",
      expected_output_type: :string,
      expected_output_text: "Hello, World!"
    }
  end
end
