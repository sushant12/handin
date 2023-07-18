now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

admin = %Handin.Accounts.User{
  email: "admin@admin.com",
  hashed_password: Bcrypt.hash_pwd_salt("admin"),
  confirmed_at: now,
  role: "admin"
}

Handin.Repo.insert(admin)

student = %Handin.Accounts.User{
  email: "student@studentmail.ul.ie",
  hashed_password: Bcrypt.hash_pwd_salt("unique password"),
  confirmed_at: now,
  role: "student"
}

Handin.Repo.insert(student)

lecturer = %Handin.Accounts.User{
  email: "padmasir@studentmail.ul.ie",
  hashed_password: Bcrypt.hash_pwd_salt("unique password"),
  confirmed_at: now,
  role: "lecturer"
}

Handin.Repo.insert(lecturer)

teacher = %Handin.Accounts.User{
  email: "teacher@studentmail.ul.ie",
  hashed_password: Bcrypt.hash_pwd_salt("unique password"),
  confirmed_at: now,
  role: "teacher"
}

Handin.Repo.insert(teacher)
