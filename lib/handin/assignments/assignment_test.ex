defmodule Handin.Assignments.AssignmentTest do
  use Handin.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Handin.Assignments
  alias Handin.Assignments.{Assignment, Log, TestResult, AssignmentTest}
  alias Handin.SupportFileUploader

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
    |> maybe_validate_file_name(attrs)
    |> maybe_parse_and_save_expected_output_file_content
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
    |> maybe_validate_file_name(attrs)
    |> maybe_parse_and_save_expected_output_file_content()
  end

  defp maybe_parse_and_save_expected_output_file_content(changeset) do
    if changeset.errors[:expected_output_file] do
      changeset
    else
      case get_change(changeset, :expected_output_file) do
        nil ->
          changeset

        expected_output_file ->
          url =
            SupportFileUploader.url(
              {expected_output_file,
               Assignments.get_support_file_by_name!(
                 get_field(changeset, :assignment_id),
                 expected_output_file
               )},
              signed: true
            )

          {:ok, %Finch.Response{status: 200, body: body}} =
            Finch.build(:get, url)
            |> Finch.request(Handin.Finch)

          put_change(changeset, :expected_output_file_content, String.trim(body))
      end
    end
  end

  defp maybe_validate_expected_output_type(changeset) do
    case get_field(changeset, :expected_output_type) do
      :file ->
        changeset |> validate_required([:expected_output_file])

      :string ->
        if get_field(changeset, :enable_custom_test) == true do
          validate_required(changeset, [:expected_output_text])
        else
          changeset
        end
    end
  end

  defp maybe_validate_file_name(changeset, _attrs) do
    case get_change(changeset, :expected_output_file) do
      nil ->
        changeset

      file_name ->
        changeset
        |> get_field(:assignment)
        |> Map.get(:support_files)
        |> Enum.find(&(&1.file.file_name == file_name))
        |> case do
          nil -> add_error(changeset, :expected_output_file, "File does not exist")
          _ -> changeset
        end
    end
  end

  defp maybe_validate_points_on_pass(changeset) do
    case get_change(changeset, :points_on_pass) do
      nil ->
        changeset

      points_on_pass ->
        assignment = get_field(changeset, :assignment)

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
        assignment = get_field(changeset, :assignment)

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
