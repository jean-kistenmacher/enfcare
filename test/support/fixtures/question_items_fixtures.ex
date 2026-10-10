defmodule App.Question_itemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Question_items` context.
  """

  @doc """
  Generate a question_item.
  """
  def question_item_fixture(attrs \\ %{}) do
    {:ok, question_item} =
      attrs
      |> Enum.into(%{
        is_user: true,
        name: "some name",
        text: "some text"
      })
      |> App.Question_items.create_question_item()

    question_item
  end
end
