defmodule App.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :image, :string
    field :message, :string
    field :is_user, :boolean, default: false
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:message, :user_id, :is_user, :image])
    |> validate_required([:message, :user_id, :is_user])
  end
end
