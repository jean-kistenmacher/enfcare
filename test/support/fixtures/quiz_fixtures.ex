defmodule App.QuizFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Quiz` context.
  """

  @doc """
  Generate a quiz_point.
  """
  def quiz_point_fixture(attrs \\ %{}) do
    {:ok, quiz_point} =
      attrs
      |> Enum.into(%{
        points: 42,
        theme: "some theme"
      })
      |> App.Quiz.create_quiz_point()

    quiz_point
  end
end
