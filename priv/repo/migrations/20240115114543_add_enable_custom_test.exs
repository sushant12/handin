defmodule Handin.Repo.Migrations.AddEnableCustomTest do
  use Ecto.Migration

  def change do
    alter table(:assignment_tests) do
      add :enable_custom_test, :boolean
      add :custom_test, :string
    end
  end
end
