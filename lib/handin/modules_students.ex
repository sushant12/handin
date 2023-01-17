defmodule Handin.ModulesStudents do
  use Ecto.Schema
  import Ecto.Changeset

  schema "modules_students" do
    belongs_to :module, Handin.Modules.Module
    belongs_to :user, Handin.Accounts.User

    timestamps()
  end

  def changeset(module_student, attrs) do
    module_student
    |> cast(attrs, [:module_id, :user_id])
    |> validate_required([:module_id, :user_id])
  end
end
