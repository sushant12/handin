defmodule HandinWeb.UniversityLiveTest do
  use HandinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Handin.UniversitiesFixtures

  @create_attrs %{name: "some name", config: %{}}
  @update_attrs %{name: "some updated name", config: %{}}
  @invalid_attrs %{name: nil, config: nil}

  defp create_university(_) do
    university = university_fixture()
    %{university: university}
  end

  describe "Index" do
    setup [:create_university]

    test "lists all universities", %{conn: conn, university: university} do
      {:ok, _index_live, html} = live(conn, ~p"/universities")

      assert html =~ "Listing Universities"
      assert html =~ university.name
    end

    test "saves new university", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/universities")

      assert index_live |> element("a", "New University") |> render_click() =~
               "New University"

      assert_patch(index_live, ~p"/universities/new")

      assert index_live
             |> form("#university-form", university: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#university-form", university: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/universities")

      html = render(index_live)
      assert html =~ "University created successfully"
      assert html =~ "some name"
    end

    test "updates university in listing", %{conn: conn, university: university} do
      {:ok, index_live, _html} = live(conn, ~p"/universities")

      assert index_live |> element("#universities-#{university.id} a", "Edit") |> render_click() =~
               "Edit University"

      assert_patch(index_live, ~p"/universities/#{university}/edit")

      assert index_live
             |> form("#university-form", university: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#university-form", university: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/universities")

      html = render(index_live)
      assert html =~ "University updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes university in listing", %{conn: conn, university: university} do
      {:ok, index_live, _html} = live(conn, ~p"/universities")

      assert index_live |> element("#universities-#{university.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#universities-#{university.id}")
    end
  end

  describe "Show" do
    setup [:create_university]

    test "displays university", %{conn: conn, university: university} do
      {:ok, _show_live, html} = live(conn, ~p"/universities/#{university}")

      assert html =~ "Show University"
      assert html =~ university.name
    end

    test "updates university within modal", %{conn: conn, university: university} do
      {:ok, show_live, _html} = live(conn, ~p"/universities/#{university}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit University"

      assert_patch(show_live, ~p"/universities/#{university}/show/edit")

      assert show_live
             |> form("#university-form", university: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#university-form", university: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/universities/#{university}")

      html = render(show_live)
      assert html =~ "University updated successfully"
      assert html =~ "some updated name"
    end
  end
end
