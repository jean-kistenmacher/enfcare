defmodule App.GameficationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Gamefications` context.
  """

  @doc """
  Generate a gamefication.
  """
  def gamefication_fixture(attrs \\ %{}) do
    {:ok, gamefication} =
      attrs
      |> Enum.into(%{
        total_articles: 42,
        total_discard_game: 42,
        total_questions_game: 42,
        user_id: 42
      })
      |> App.Gamefications.create_gamefication()

    gamefication
  end
end
