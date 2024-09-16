defmodule Handin.Repo.Migrations.ChangeTeachingAssistantToStudent do
  use Ecto.Migration

  def change do
    execute "UPDATE users SET role = 'student' WHERE role = 'teaching_assistant'"
  end
end
