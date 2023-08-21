alias Handin.Repo
now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

%Handin.Accounts.User{
  email: "admin@admin.com",
  hashed_password: Bcrypt.hash_pwd_salt("admin"),
  confirmed_at: now,
  role: "admin"
}
|> Repo.insert!()

%Handin.Accounts.User{
  email: "student3@studentmail.ul.ie",
  hashed_password: Bcrypt.hash_pwd_salt("student"),
  confirmed_at: now,
  role: "student"
}
|> Repo.insert!()

%Handin.Accounts.User{
  email: "paddy@ul.ie",
  hashed_password: Bcrypt.hash_pwd_salt("paddy"),
  confirmed_at: now,
  role: "lecturer"
}
|> Repo.insert!()

%Handin.Universities.University{
  name: "University Of Limerick",
  student_email_regex: "^\\d+@studentmail\.ul\.ie$"
}
|> Repo.insert!()

%Handin.Universities.University{
  name: "University College Cork",
  student_email_regex: "^\\d+@studentmail\.ucc\.ie$"
}
|> Repo.insert!()

%Handin.ProgrammingLanguages.ProgrammingLanguage{
  name: "Cpp",
  docker_file_url: "sushantbajracharya/cpp:latest"
}
|> Repo.insert!()
