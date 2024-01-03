defmodule Handin.AssignmentSubmission.AssignmentSubmission do
  alias Handin.AssignmentSubmission.AssignmentSubmissionFile
  alias Handin.Accounts.User
  alias Handin.Assignments.{Assignment}

  use Handin.Schema

  import Ecto.Changeset
  @type t :: %__MODULE__{}
  schema "assignment_submissions" do
    field :submitted_at, :utc_datetime
    field :retries, :integer, default: 0
    field :total_points, :float, default: 0.0

    belongs_to :user, User
    belongs_to :assignment, Assignment
    has_many :assignment_submission_files, AssignmentSubmissionFile, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @required_attrs [:user_id, :assignment_id]
  @attrs [:submitted_at, :retries, :total_points] ++ @required_attrs
  def changeset(assignment_submission, attrs) do
    assignment_submission
    |> cast(attrs, @attrs)
    |> cast_assoc(:assignment_submission_files)
    |> validate_required(@required_attrs)
    |> unique_constraint([:assignment_id, :user_id])
    |> maybe_validate_total_points()
  end

  defp maybe_validate_total_points(changeset) do
    case get_change(changeset, :total_points) do
      nil ->
        changeset

      total_points ->
        assignment = get_field(changeset, :assignment)
        if assignment.enable_total_marks && (total_points > assignment.total_marks || total_points < -assignment.total_marks) do
          add_error(changeset, :total_points, "Total points exceeds total marks")
        else
          changeset
        end
    end
  end
end
