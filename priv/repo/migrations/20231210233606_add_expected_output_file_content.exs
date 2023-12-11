defmodule Handin.Repo.Migrations.AddExpectedOutputFileContent do
  use Ecto.Migration

  def change do
    alter table(:assignment_tests) do
      add :expected_output_file_content, :text
    end
  end
end
