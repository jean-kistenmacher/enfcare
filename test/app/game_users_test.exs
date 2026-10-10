defmodule App.Game_usersTest do
  use App.DataCase

  alias App.Game_users

  describe "game_user" do
    alias App.Game_users.Game_user

    import App.Game_usersFixtures

    @invalid_attrs %{points: nil}

    test "list_game_user/0 returns all game_user" do
      game_user = game_user_fixture()
      assert Game_users.list_game_user() == [game_user]
    end

    test "get_game_user!/1 returns the game_user with given id" do
      game_user = game_user_fixture()
      assert Game_users.get_game_user!(game_user.id) == game_user
    end

    test "create_game_user/1 with valid data creates a game_user" do
      valid_attrs = %{points: 42}

      assert {:ok, %Game_user{} = game_user} = Game_users.create_game_user(valid_attrs)
      assert game_user.points == 42
    end

    test "create_game_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game_users.create_game_user(@invalid_attrs)
    end

    test "update_game_user/2 with valid data updates the game_user" do
      game_user = game_user_fixture()
      update_attrs = %{points: 43}

      assert {:ok, %Game_user{} = game_user} = Game_users.update_game_user(game_user, update_attrs)
      assert game_user.points == 43
    end

    test "update_game_user/2 with invalid data returns error changeset" do
      game_user = game_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Game_users.update_game_user(game_user, @invalid_attrs)
      assert game_user == Game_users.get_game_user!(game_user.id)
    end

    test "delete_game_user/1 deletes the game_user" do
      game_user = game_user_fixture()
      assert {:ok, %Game_user{}} = Game_users.delete_game_user(game_user)
      assert_raise Ecto.NoResultsError, fn -> Game_users.get_game_user!(game_user.id) end
    end

    test "change_game_user/1 returns a game_user changeset" do
      game_user = game_user_fixture()
      assert %Ecto.Changeset{} = Game_users.change_game_user(game_user)
    end
  end
end
