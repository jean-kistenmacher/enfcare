defmodule App.QuizTest do
  use App.DataCase

  alias App.Quiz

  describe "quiz_points" do
    alias App.Quiz.Quiz_point

    import App.QuizFixtures

    @invalid_attrs %{points: nil, theme: nil}

    test "list_quiz_points/0 returns all quiz_points" do
      quiz_point = quiz_point_fixture()
      assert Quiz.list_quiz_points() == [quiz_point]
    end

    test "get_quiz_point!/1 returns the quiz_point with given id" do
      quiz_point = quiz_point_fixture()
      assert Quiz.get_quiz_point!(quiz_point.id) == quiz_point
    end

    test "create_quiz_point/1 with valid data creates a quiz_point" do
      valid_attrs = %{points: 42, theme: "some theme"}

      assert {:ok, %Quiz_point{} = quiz_point} = Quiz.create_quiz_point(valid_attrs)
      assert quiz_point.points == 42
      assert quiz_point.theme == "some theme"
    end

    test "create_quiz_point/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quiz.create_quiz_point(@invalid_attrs)
    end

    test "update_quiz_point/2 with valid data updates the quiz_point" do
      quiz_point = quiz_point_fixture()
      update_attrs = %{points: 43, theme: "some updated theme"}

      assert {:ok, %Quiz_point{} = quiz_point} = Quiz.update_quiz_point(quiz_point, update_attrs)
      assert quiz_point.points == 43
      assert quiz_point.theme == "some updated theme"
    end

    test "update_quiz_point/2 with invalid data returns error changeset" do
      quiz_point = quiz_point_fixture()
      assert {:error, %Ecto.Changeset{}} = Quiz.update_quiz_point(quiz_point, @invalid_attrs)
      assert quiz_point == Quiz.get_quiz_point!(quiz_point.id)
    end

    test "delete_quiz_point/1 deletes the quiz_point" do
      quiz_point = quiz_point_fixture()
      assert {:ok, %Quiz_point{}} = Quiz.delete_quiz_point(quiz_point)
      assert_raise Ecto.NoResultsError, fn -> Quiz.get_quiz_point!(quiz_point.id) end
    end

    test "change_quiz_point/1 returns a quiz_point changeset" do
      quiz_point = quiz_point_fixture()
      assert %Ecto.Changeset{} = Quiz.change_quiz_point(quiz_point)
    end
  end
end
