alias Handin.Accounts.Role
alias Handin.Repo
now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
role = Role |> Repo.all()

%Handin.Accounts.User{
  email: "admin@admin.com",
  hashed_password: Bcrypt.hash_pwd_salt("admin"),
  confirmed_at: now,
  admin: true
}
|> Repo.insert!()

student_role = role |> Enum.find(&(&1.name == "Student"))

%Handin.Accounts.User{
  email: "student@studentmail.ul.ie",
  hashed_password: Bcrypt.hash_pwd_salt("student"),
  confirmed_at: now,
  roles: [student_role]
}
|> Repo.insert!()

lecturer_role = role |> Enum.find(&(&1.name == "Lecturer"))

%Handin.Accounts.User{
  email: "paddy@ul.ie",
  hashed_password: Bcrypt.hash_pwd_salt("paddy"),
  confirmed_at: now,
  roles: [lecturer_role]
}
|> Repo.insert!()

ta_role = role |> Enum.find(&(&1.name == "Teaching Assistant"))

%Handin.Accounts.User{
  email: "ta@studentmail.ul.ie",
  hashed_password: Bcrypt.hash_pwd_salt("teaching_assistant"),
  confirmed_at: now,
  roles: [ta_role]
}
|> Repo.insert!()
