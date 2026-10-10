defmodule App.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Chats` context.
  """

  @doc """
  Generate a chat.
  """
  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      attrs
      |> Enum.into(%{
        image: "some image",
        message: "some message"
      })
      |> App.Chats.create_chat()

    chat
  end
end
