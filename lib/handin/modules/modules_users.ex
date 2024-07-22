defmodule Handin.Modules.ModulesUsers do
  use Handin.Schema
  import Ecto.Changeset
  @type t :: %__MODULE__{}

  schema "modules_users" do
    field :role, Ecto.Enum,
      default: :student,
      values: [:student, :admin, :lecturer, :teaching_assistant]

    belongs_to :module, Handin.Modules.Module
    belongs_to :user, Handin.Accounts.User
    timestamps()
  end

  def changeset(module_user, attrs) do
    module_user
    |> cast(attrs, [:module_id, :user_id, :role])
    |> validate_required([:module_id, :user_id])
    |> unique_constraint([:module_id, :user_id])
  end
end
