defmodule Handin.Assignments.CustomAssignmentDate do
  use Handin.Schema

  import Ecto.Changeset

  schema "custom_assignment_dates" do
    field :start_date, :naive_datetime
    field :due_date, :naive_datetime
    field :enable_cutoff_date, :boolean, default: false
    field :cutoff_date, :naive_datetime

    belongs_to :assignment, Handin.Assignments.Assignment
    belongs_to :user, Handin.Accounts.User

    timestamps()
  end

  @req_attrs [:user_id, :assignment_id]

  @attrs [:start_date, :due_date, :enable_cutoff_date, :cutoff_date, :assignment_id, :user_id]
  def changeset(custom_assignment_date, attrs) do
    custom_assignment_date
    |> cast(attrs, @attrs)
    |> validate_required(@req_attrs)
    |> maybe_validate_start_date(attrs)
    |> maybe_validate_due_date()
    |> maybe_validate_cutoff_date()
  end

  defp maybe_validate_start_date(changeset, attrs) do
    case get_change(changeset, :start_date) do
      nil ->
        changeset

      start_date ->
        now = DateTime.utc_now() |> DateTime.shift_zone!(attrs["timezone"]) |> DateTime.to_naive()

        if NaiveDateTime.compare(start_date, now) == :lt do
          add_error(changeset, :start_date, "must be in the future")
        else
          changeset
        end
    end
  end

  defp maybe_validate_due_date(changeset) do
    case get_field(changeset, :due_date) do
      nil ->
        changeset

      due_date ->
        start_date = get_field(changeset, :start_date)

        if start_date && NaiveDateTime.compare(due_date, start_date) == :lt do
          add_error(changeset, :due_date, "must come after start date")
        else
          changeset
        end
    end
  end

  defp maybe_validate_cutoff_date(changeset) do
    if get_field(changeset, :enable_cutoff_date) do
      start_date = get_field(changeset, :start_date)
      due_date = get_field(changeset, :due_date)

      changeset =
        changeset
        |> validate_required(:cutoff_date)

      case get_field(changeset, :cutoff_date) do
        nil ->
          changeset

        cutoff_date ->
          if start_date && due_date && NaiveDateTime.compare(cutoff_date, due_date) == :lt do
            changeset
            |> add_error(:cutoff_date, "must come after start date and due date")
          else
            changeset
          end
      end
    else
      changeset
    end
  end
end
