defmodule Handin.Assignments.AssignmentTest do
  use Handin.Schema
  import Ecto.Changeset
  alias Handin.Assignments
  alias Handin.Assignments.{Assignment, Log, TestResult}
  alias Handin.SupportFileUploader

  schema "assignment_tests" do
    field :name, :string
    field :points_on_pass, :float
    field :points_on_fail, :float
    field :command, :string
    field :expected_output_type, :string
    field :expected_output_text, :string
    field :expected_output_file, :string
    field :expected_output_file_content, :string
    field :ttl, :integer, default: 0

    belongs_to :assignment, Assignment

    has_many :logs, Log
    has_many :test_results, TestResult

    timestamps()
  end

  @required_attrs [
    :name,
    :assignment_id,
    :points_on_pass,
    :points_on_fail,
    :command,
    :expected_output_type
  ]

  @attrs @required_attrs ++
           [
             :expected_output_text,
             :expected_output_file,
             :expected_output_file_content,
             :ttl
           ]

  @doc false
  def changeset(assignment_test, attrs) do
    assignment_test
    |> cast(attrs, @attrs)
    |> validate_required(@required_attrs)
    |> maybe_validate_expected_output_type()
    |> maybe_validate_file_name(attrs)
    |> validate_number(:ttl , less_than_or_equal_to: 60, greater_than_or_equal_to: 0)
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

          put_change(changeset, :expected_output_file_content, body)
      end
    end
  end

  defp maybe_validate_expected_output_type(changeset) do
    case get_change(changeset, :expected_output_type) do
      "file" -> changeset |> validate_required([:expected_output_file])
      "text" -> changeset |> validate_required([:expected_output_text])
      _ -> changeset
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
end
