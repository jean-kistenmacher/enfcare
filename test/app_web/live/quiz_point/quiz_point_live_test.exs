defmodule AppWeb.QuizPoint.Quiz_pointLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.QuizFixtures

  @create_attrs %{points: 42, theme: "some theme"}
  @update_attrs %{points: 43, theme: "some updated theme"}
  @invalid_attrs %{points: nil, theme: nil}

  defp create_quiz_point(_) do
    quiz_point = quiz_point_fixture()
    %{quiz_point: quiz_point}
  end

  describe "Index" do
    setup [:create_quiz_point]

    test "lists all quiz_points", %{conn: conn, quiz_point: quiz_point} do
      {:ok, _index_live, html} = live(conn, ~p"/quiz_point/quiz_points")

      assert html =~ "Listing Quiz points"
      assert html =~ quiz_point.theme
    end

    test "saves new quiz_point", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/quiz_point/quiz_points")

      assert index_live |> element("a", "New Quiz point") |> render_click() =~
               "New Quiz point"

      assert_patch(index_live, ~p"/quiz_point/quiz_points/new")

      assert index_live
             |> form("#quiz_point-form", quiz_point: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#quiz_point-form", quiz_point: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/quiz_point/quiz_points")

      html = render(index_live)
      assert html =~ "Quiz point created successfully"
      assert html =~ "some theme"
    end

    test "updates quiz_point in listing", %{conn: conn, quiz_point: quiz_point} do
      {:ok, index_live, _html} = live(conn, ~p"/quiz_point/quiz_points")

      assert index_live |> element("#quiz_points-#{quiz_point.id} a", "Edit") |> render_click() =~
               "Edit Quiz point"

      assert_patch(index_live, ~p"/quiz_point/quiz_points/#{quiz_point}/edit")

      assert index_live
             |> form("#quiz_point-form", quiz_point: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#quiz_point-form", quiz_point: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/quiz_point/quiz_points")

      html = render(index_live)
      assert html =~ "Quiz point updated successfully"
      assert html =~ "some updated theme"
    end

    test "deletes quiz_point in listing", %{conn: conn, quiz_point: quiz_point} do
      {:ok, index_live, _html} = live(conn, ~p"/quiz_point/quiz_points")

      assert index_live |> element("#quiz_points-#{quiz_point.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#quiz_points-#{quiz_point.id}")
    end
  end

  describe "Show" do
    setup [:create_quiz_point]

    test "displays quiz_point", %{conn: conn, quiz_point: quiz_point} do
      {:ok, _show_live, html} = live(conn, ~p"/quiz_point/quiz_points/#{quiz_point}")

      assert html =~ "Show Quiz point"
      assert html =~ quiz_point.theme
    end

    test "updates quiz_point within modal", %{conn: conn, quiz_point: quiz_point} do
      {:ok, show_live, _html} = live(conn, ~p"/quiz_point/quiz_points/#{quiz_point}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Quiz point"

      assert_patch(show_live, ~p"/quiz_point/quiz_points/#{quiz_point}/show/edit")

      assert show_live
             |> form("#quiz_point-form", quiz_point: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#quiz_point-form", quiz_point: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/quiz_point/quiz_points/#{quiz_point}")

      html = render(show_live)
      assert html =~ "Quiz point updated successfully"
      assert html =~ "some updated theme"
    end
  end
end
