defmodule Handin.ProgrammingLanguagesTest do
  use Handin.DataCase

  alias Handin.ProgrammingLanguages

  describe "programming_languages" do
    alias Handin.ProgrammingLanguages.ProgrammingLanguage

    import Handin.ProgrammingLanguagesFixtures

    @invalid_attrs %{name: nil, docker_file_url: nil}

    test "list_programming_languages/0 returns all programming_languages" do
      programming_language = programming_language_fixture()
      assert ProgrammingLanguages.list_programming_languages() == [programming_language]
    end

    test "get_programming_language!/1 returns the programming_language with given id" do
      programming_language = programming_language_fixture()

      assert ProgrammingLanguages.get_programming_language!(programming_language.id) ==
               programming_language
    end

    test "create_programming_language/1 with valid data creates a programming_language" do
      valid_attrs = %{name: "some name", docker_file_url: "some docker_file_url"}

      assert {:ok, %ProgrammingLanguage{} = programming_language} =
               ProgrammingLanguages.create_programming_language(valid_attrs)

      assert programming_language.name == "some name"
      assert programming_language.docker_file_url == "some docker_file_url"
    end

    test "create_programming_language/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               ProgrammingLanguages.create_programming_language(@invalid_attrs)
    end

    test "update_programming_language/2 with valid data updates the programming_language" do
      programming_language = programming_language_fixture()
      update_attrs = %{name: "some updated name", docker_file_url: "some updated docker_file_url"}

      assert {:ok, %ProgrammingLanguage{} = programming_language} =
               ProgrammingLanguages.update_programming_language(
                 programming_language,
                 update_attrs
               )

      assert programming_language.name == "some updated name"
      assert programming_language.docker_file_url == "some updated docker_file_url"
    end

    test "update_programming_language/2 with invalid data returns error changeset" do
      programming_language = programming_language_fixture()

      assert {:error, %Ecto.Changeset{}} =
               ProgrammingLanguages.update_programming_language(
                 programming_language,
                 @invalid_attrs
               )

      assert programming_language ==
               ProgrammingLanguages.get_programming_language!(programming_language.id)
    end

    test "delete_programming_language/1 deletes the programming_language" do
      programming_language = programming_language_fixture()

      assert {:ok, %ProgrammingLanguage{}} =
               ProgrammingLanguages.delete_programming_language(programming_language)

      assert_raise Ecto.NoResultsError, fn ->
        ProgrammingLanguages.get_programming_language!(programming_language.id)
      end
    end

    test "change_programming_language/1 returns a programming_language changeset" do
      programming_language = programming_language_fixture()

      assert %Ecto.Changeset{} =
               ProgrammingLanguages.change_programming_language(programming_language)
    end
  end
end
