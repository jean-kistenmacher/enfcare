defmodule App.GameficationsTest do
  use App.DataCase

  alias App.Gamefications

  describe "gamefications" do
    alias App.Gamefications.Gamefication

    import App.GameficationsFixtures

    @invalid_attrs %{total_articles: nil, total_discard_game: nil, total_questions_game: nil, user_id: nil}

    test "list_gamefications/0 returns all gamefications" do
      gamefication = gamefication_fixture()
      assert Gamefications.list_gamefications() == [gamefication]
    end

    test "get_gamefication!/1 returns the gamefication with given id" do
      gamefication = gamefication_fixture()
      assert Gamefications.get_gamefication!(gamefication.id) == gamefication
    end

    test "create_gamefication/1 with valid data creates a gamefication" do
      valid_attrs = %{total_articles: 42, total_discard_game: 42, total_questions_game: 42, user_id: 42}

      assert {:ok, %Gamefication{} = gamefication} = Gamefications.create_gamefication(valid_attrs)
      assert gamefication.total_articles == 42
      assert gamefication.total_discard_game == 42
      assert gamefication.total_questions_game == 42
      assert gamefication.user_id == 42
    end

    test "create_gamefication/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gamefications.create_gamefication(@invalid_attrs)
    end

    test "update_gamefication/2 with valid data updates the gamefication" do
      gamefication = gamefication_fixture()
      update_attrs = %{total_articles: 43, total_discard_game: 43, total_questions_game: 43, user_id: 43}

      assert {:ok, %Gamefication{} = gamefication} = Gamefications.update_gamefication(gamefication, update_attrs)
      assert gamefication.total_articles == 43
      assert gamefication.total_discard_game == 43
      assert gamefication.total_questions_game == 43
      assert gamefication.user_id == 43
    end

    test "update_gamefication/2 with invalid data returns error changeset" do
      gamefication = gamefication_fixture()
      assert {:error, %Ecto.Changeset{}} = Gamefications.update_gamefication(gamefication, @invalid_attrs)
      assert gamefication == Gamefications.get_gamefication!(gamefication.id)
    end

    test "delete_gamefication/1 deletes the gamefication" do
      gamefication = gamefication_fixture()
      assert {:ok, %Gamefication{}} = Gamefications.delete_gamefication(gamefication)
      assert_raise Ecto.NoResultsError, fn -> Gamefications.get_gamefication!(gamefication.id) end
    end

    test "change_gamefication/1 returns a gamefication changeset" do
      gamefication = gamefication_fixture()
      assert %Ecto.Changeset{} = Gamefications.change_gamefication(gamefication)
    end
  end
end
