defmodule Handin.Assignments.SupportFile do
  use Handin.Schema
  import Ecto.Changeset
  use Waffle.Ecto.Schema

  alias Handin.Assignments.Assignment
  @type t :: %__MODULE__{}
  schema "support_files" do
    field :file, Handin.SupportFileUploader.Type

    belongs_to :assignment, Assignment

    timestamps()
  end

  def changeset(support_file, attrs) do
    support_file
    |> cast(attrs, [:assignment_id])
    |> validate_required([:assignment_id])
  end

  def file_changeset(support_file, attrs) do
    support_file
    |> cast_attachments(attrs, [:file])
    |> validate_required([:file])
  end

  def clone_changeset(support_file, attrs) do
    support_file
    |> cast(attrs, [:assignment_id, :file])
    |> validate_required([:assignment_id, :file])
  end
end
