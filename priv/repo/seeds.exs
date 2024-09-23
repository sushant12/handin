alias Handin.Repo
now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

admin =
  %Handin.Accounts.User{
    email: "admin@handin.org",
    hashed_password: Bcrypt.hash_pwd_salt("admin"),
    confirmed_at: now,
    role: :admin
  }
  |> Repo.insert!()

%Handin.Accounts.User{
  email: "paddy@ul.ie",
  hashed_password: Bcrypt.hash_pwd_salt("paddy"),
  confirmed_at: now,
  role: :lecturer
}
|> Repo.insert!()

programming_language =
  %Handin.ProgrammingLanguages.ProgrammingLanguage{
    name: "cpp",
    docker_file_url: "sushantbajracharya/cpp:latest"
  }
  |> Repo.insert!()

module =
  %Handin.Modules.Module{
    name: "Data Structure and Algorithms",
    code: "CS100"
  }
  |> Repo.insert!()

%Handin.Modules.ModulesUsers{
  module_id: module.id,
  user_id: admin.id
}
|> Repo.insert!()

assignment =
  %Handin.Assignments.Assignment{
    name: "Week 0",
    start_date: now,
    due_date: NaiveDateTime.add(now, 2, :day),
    programming_language_id: programming_language.id,
    module_id: module.id,
    run_script: "g++ main.cpp -o main"
  }
  |> Repo.insert!()

1..4
|> Enum.each(fn i ->
  %Handin.Assignments.AssignmentTest{
    assignment_id: assignment.id,
    name: "Test #{i}",
    command: "./main #{i} 2",
    expected_output_type: :string,
    expected_output_text: "3"
  }
  |> Repo.insert!()
end)

1..20
|> Enum.each(fn i ->
  user =
    %Handin.Accounts.User{
      email: "#{i}@studentmail.ul.ie",
      hashed_password: Bcrypt.hash_pwd_salt("password"),
      confirmed_at: now,
      role: :student
    }
    |> Repo.insert!()

  %Handin.Modules.ModulesUsers{
    module_id: module.id,
    user_id: user.id
  }
  |> Repo.insert!()
end)
