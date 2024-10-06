defmodule Handin.Assignments.AssignmentTest do
  use Handin.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Handin.Assignments.{Assignment, Log, TestResult, AssignmentTest}
  @type t :: %__MODULE__{}
  schema "assignment_tests" do
    field :name, :string
    field :points_on_pass, :float, default: 0.0
    field :points_on_fail, :float, default: 0.0
    field :command, :string
    field :expected_output_type, Ecto.Enum, values: [:string, :file], default: :string
    field :expected_output_text, :string
    field :expected_output_file, :string
    field :expected_output_file_content, :string
    field :ttl, :integer, default: 60
    field :enable_custom_test, :boolean, default: false
    field :custom_test, :string

    belongs_to :assignment, Assignment

    has_many :logs, Log
    has_many :test_results, TestResult, on_delete: :delete_all

    timestamps()
  end

  @required_attrs [
    :name,
    :assignment_id
  ]

  @attrs @required_attrs ++
           [
             :command,
             :expected_output_type,
             :points_on_pass,
             :points_on_fail,
             :expected_output_text,
             :expected_output_file,
             :expected_output_file_content,
             :ttl,
             :enable_custom_test,
             :custom_test
           ]

  @doc false
  def changeset(assignment_test, attrs) do
    assignment_test
    |> cast(attrs, @attrs)
    |> validate_required(@required_attrs)
    |> maybe_validate_custom_test()
    |> maybe_validate_expected_output_type()
    |> maybe_validate_points_on_pass()
    |> maybe_validate_points_on_fail()
  end

  def new_changeset(assignment_test, attrs) do
    assignment_test
    |> cast(attrs, @attrs)
  end

  def output_file_changeset(assignment_test, attrs) do
    assignment_test
    |> cast(attrs, @attrs)
  end

  defp maybe_validate_expected_output_type(changeset) do
    case get_field(changeset, :expected_output_type) do
      :file ->
        changeset |> validate_required([:expected_output_file])

      :string ->
        if get_field(changeset, :enable_custom_test),
          do: changeset,
          else: validate_required(changeset, [:expected_output_text])

      _ ->
        changeset
    end
  end

  defp maybe_validate_points_on_pass(changeset) do
    case get_change(changeset, :points_on_pass) do
      nil ->
        changeset

      points_on_pass ->
        assignment =
          changeset.data
          |> Handin.Repo.preload(:assignment)
          |> Map.get(:assignment)

        total_marks =
          AssignmentTest
          |> where(
            [at],
            at.assignment_id == ^assignment.id and at.id != ^get_field(changeset, :id)
          )
          |> Handin.Repo.all()
          |> Enum.reduce(0, fn assignment_test, acc -> assignment_test.points_on_pass + acc end)

        total_marks =
          if assignment.enable_total_marks && assignment.enable_attempt_marks,
            do: total_marks + assignment.attempt_marks,
            else: total_marks

        if total_marks + points_on_pass > assignment.total_marks do
          add_error(
            changeset,
            :points_on_pass,
            "Points exceed total marks. Please ensure points on pass assigned do not surpass the total marks."
          )
        else
          changeset
        end
    end
  end

  defp maybe_validate_points_on_fail(changeset) do
    case get_change(changeset, :points_on_fail) do
      nil ->
        changeset

      points_on_fail ->
        assignment = changeset.data |> Handin.Repo.preload(:assignment) |> Map.get(:assignment)

        total_marks =
          AssignmentTest
          |> where(
            [at],
            at.assignment_id == ^assignment.id and at.id != ^get_field(changeset, :id)
          )
          |> Handin.Repo.all()
          |> Enum.reduce(0, fn assignment_test, acc -> assignment_test.points_on_fail + acc end)

        if total_marks + points_on_fail > assignment.total_marks do
          add_error(
            changeset,
            :points_on_fail,
            "Points exceed total marks. Please ensure points on fail assigned do not surpass the total marks."
          )
        else
          changeset
        end
    end
  end

  defp maybe_validate_custom_test(changeset) do
    if get_field(changeset, :enable_custom_test) do
      validate_required(changeset, :custom_test)
    else
      validate_required(changeset, [:command, :expected_output_type])
    end
  end
end
