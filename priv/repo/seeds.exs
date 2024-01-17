alias Handin.Repo
now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

university =
  %Handin.Universities.University{
    name: "University Of Limerick",
    student_email_regex: "^\\d+@studentmail\.ul\.ie$",
    timezone: "Europe/Dublin"
  }
  |> Repo.insert!()

%Handin.Universities.University{
  name: "University College Cork",
  student_email_regex: "^\\d+@studentmail\.ucc\.ie$",
  timezone: "Europe/Dublin"
}
|> Repo.insert!()

admin =
  %Handin.Accounts.User{
    email: "admin@admin.com",
    hashed_password: Bcrypt.hash_pwd_salt("admin"),
    confirmed_at: now,
    role: :admin,
    university_id: university.id
  }
  |> Repo.insert!()

%Handin.Accounts.User{
  email: "student3@studentmail.ul.ie",
  hashed_password: Bcrypt.hash_pwd_salt("student"),
  confirmed_at: now,
  role: :student,
  university_id: university.id
}
|> Repo.insert!()

%Handin.Accounts.User{
  email: "paddy@ul.ie",
  hashed_password: Bcrypt.hash_pwd_salt("paddy"),
  confirmed_at: now,
  role: :lecturer,
  university_id: university.id
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

%Handin.Modules.ModulesUsers{
  module_id: module.id,
  user_id: admin.id
}
|> Repo.insert!()
