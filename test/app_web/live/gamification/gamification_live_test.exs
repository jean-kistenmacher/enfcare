defmodule AppWeb.Gamefication.GameficationLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.GameficationsFixtures

  @create_attrs %{total_articles: 42, total_discard_game: 42, total_questions_game: 42, user_id: 42}
  @update_attrs %{total_articles: 43, total_discard_game: 43, total_questions_game: 43, user_id: 43}
  @invalid_attrs %{total_articles: nil, total_discard_game: nil, total_questions_game: nil, user_id: nil}

  defp create_gamefication(_) do
    gamefication = gamefication_fixture()
    %{gamefication: gamefication}
  end

  describe "Index" do
    setup [:create_gamefication]

    test "lists all gamefications", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/gamification/gamifications")

      assert html =~ "Listing Gamefications"
    end

    test "saves new gamefication", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/gamification/gamifications")

      assert index_live |> element("a", "New Gamefication") |> render_click() =~
               "New Gamefication"

      assert_patch(index_live, ~p"/gamification/gamifications/new")

      assert index_live
             |> form("#gamefication-form", gamefication: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#gamefication-form", gamefication: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/gamification/gamifications")

      html = render(index_live)
      assert html =~ "Gamefication created successfully"
    end

    test "updates gamefication in listing", %{conn: conn, gamefication: gamefication} do
      {:ok, index_live, _html} = live(conn, ~p"/gamification/gamifications")

      assert index_live |> element("#gamefications-#{gamefication.id} a", "Edit") |> render_click() =~
               "Edit Gamefication"

      assert_patch(index_live, ~p"/gamification/gamifications/#{gamefication}/edit")

      assert index_live
             |> form("#gamefication-form", gamefication: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#gamefication-form", gamefication: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/gamification/gamifications")

      html = render(index_live)
      assert html =~ "Gamefication updated successfully"
    end

    test "deletes gamefication in listing", %{conn: conn, gamefication: gamefication} do
      {:ok, index_live, _html} = live(conn, ~p"/gamification/gamifications")

      assert index_live |> element("#gamefications-#{gamefication.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#gamefications-#{gamefication.id}")
    end
  end

  describe "Show" do
    setup [:create_gamefication]

    test "displays gamefication", %{conn: conn, gamefication: gamefication} do
      {:ok, _show_live, html} = live(conn, ~p"/gamification/gamifications/#{gamefication}")

      assert html =~ "Show Gamefication"
    end

    test "updates gamefication within modal", %{conn: conn, gamefication: gamefication} do
      {:ok, show_live, _html} = live(conn, ~p"/gamification/gamifications/#{gamefication}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Gamefication"

      assert_patch(show_live, ~p"/gamification/gamifications/#{gamefication}/show/edit")

      assert show_live
             |> form("#gamefication-form", gamefication: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#gamefication-form", gamefication: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/gamification/gamifications/#{gamefication}")

      html = render(show_live)
      assert html =~ "Gamefication updated successfully"
    end
  end
end
