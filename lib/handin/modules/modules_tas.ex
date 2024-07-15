defmodule Handin.Modules.ModuleTAs do
  use Handin.Schema
  import Ecto.Changeset
  @type t :: %__MODULE__{}

  schema "modules_tas" do
    belongs_to :module, Handin.Modules.Module
    belongs_to :user, Handin.Accounts.User

    timestamps()
  end

  def changeset(module_tas, attrs) do
    module_tas
    |> cast(attrs, [:module_id, :user_id])
    |> validate_required([:module_id, :user_id])
    |> unique_constraint([:module_id, :user_id])
  end
end
