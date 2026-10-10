defmodule App.Question_itemsTest do
  use App.DataCase

  alias App.Question_items

  describe "question_items" do
    alias App.Question_items.Question_item

    import App.Question_itemsFixtures

    @invalid_attrs %{is_user: nil, name: nil, text: nil}

    test "list_question_items/0 returns all question_items" do
      question_item = question_item_fixture()
      assert Question_items.list_question_items() == [question_item]
    end

    test "get_question_item!/1 returns the question_item with given id" do
      question_item = question_item_fixture()
      assert Question_items.get_question_item!(question_item.id) == question_item
    end

    test "create_question_item/1 with valid data creates a question_item" do
      valid_attrs = %{is_user: true, name: "some name", text: "some text"}

      assert {:ok, %Question_item{} = question_item} = Question_items.create_question_item(valid_attrs)
      assert question_item.is_user == true
      assert question_item.name == "some name"
      assert question_item.text == "some text"
    end

    test "create_question_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Question_items.create_question_item(@invalid_attrs)
    end

    test "update_question_item/2 with valid data updates the question_item" do
      question_item = question_item_fixture()
      update_attrs = %{is_user: false, name: "some updated name", text: "some updated text"}

      assert {:ok, %Question_item{} = question_item} = Question_items.update_question_item(question_item, update_attrs)
      assert question_item.is_user == false
      assert question_item.name == "some updated name"
      assert question_item.text == "some updated text"
    end

    test "update_question_item/2 with invalid data returns error changeset" do
      question_item = question_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Question_items.update_question_item(question_item, @invalid_attrs)
      assert question_item == Question_items.get_question_item!(question_item.id)
    end

    test "delete_question_item/1 deletes the question_item" do
      question_item = question_item_fixture()
      assert {:ok, %Question_item{}} = Question_items.delete_question_item(question_item)
      assert_raise Ecto.NoResultsError, fn -> Question_items.get_question_item!(question_item.id) end
    end

    test "change_question_item/1 returns a question_item changeset" do
      question_item = question_item_fixture()
      assert %Ecto.Changeset{} = Question_items.change_question_item(question_item)
    end
  end
end
