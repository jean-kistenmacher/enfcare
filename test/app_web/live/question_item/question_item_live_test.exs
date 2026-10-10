defmodule AppWeb.QuestionItem.Question_itemLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.Question_itemsFixtures

  @create_attrs %{is_user: true, name: "some name", text: "some text"}
  @update_attrs %{is_user: false, name: "some updated name", text: "some updated text"}
  @invalid_attrs %{is_user: false, name: nil, text: nil}

  defp create_question_item(_) do
    question_item = question_item_fixture()
    %{question_item: question_item}
  end

  describe "Index" do
    setup [:create_question_item]

    test "lists all question_items", %{conn: conn, question_item: question_item} do
      {:ok, _index_live, html} = live(conn, ~p"/question_item/question_items")

      assert html =~ "Listing Question items"
      assert html =~ question_item.name
    end

    test "saves new question_item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/question_item/question_items")

      assert index_live |> element("a", "New Question item") |> render_click() =~
               "New Question item"

      assert_patch(index_live, ~p"/question_item/question_items/new")

      assert index_live
             |> form("#question_item-form", question_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#question_item-form", question_item: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/question_item/question_items")

      html = render(index_live)
      assert html =~ "Question item created successfully"
      assert html =~ "some name"
    end

    test "updates question_item in listing", %{conn: conn, question_item: question_item} do
      {:ok, index_live, _html} = live(conn, ~p"/question_item/question_items")

      assert index_live |> element("#question_items-#{question_item.id} a", "Edit") |> render_click() =~
               "Edit Question item"

      assert_patch(index_live, ~p"/question_item/question_items/#{question_item}/edit")

      assert index_live
             |> form("#question_item-form", question_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#question_item-form", question_item: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/question_item/question_items")

      html = render(index_live)
      assert html =~ "Question item updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes question_item in listing", %{conn: conn, question_item: question_item} do
      {:ok, index_live, _html} = live(conn, ~p"/question_item/question_items")

      assert index_live |> element("#question_items-#{question_item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#question_items-#{question_item.id}")
    end
  end

  describe "Show" do
    setup [:create_question_item]

    test "displays question_item", %{conn: conn, question_item: question_item} do
      {:ok, _show_live, html} = live(conn, ~p"/question_item/question_items/#{question_item}")

      assert html =~ "Show Question item"
      assert html =~ question_item.name
    end

    test "updates question_item within modal", %{conn: conn, question_item: question_item} do
      {:ok, show_live, _html} = live(conn, ~p"/question_item/question_items/#{question_item}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Question item"

      assert_patch(show_live, ~p"/question_item/question_items/#{question_item}/show/edit")

      assert show_live
             |> form("#question_item-form", question_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#question_item-form", question_item: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/question_item/question_items/#{question_item}")

      html = render(show_live)
      assert html =~ "Question item updated successfully"
      assert html =~ "some updated name"
    end
  end
end
