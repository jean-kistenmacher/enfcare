defmodule App.QuestionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Questions` context.
  """

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> App.Questions.create_question()

    question
  end
end
