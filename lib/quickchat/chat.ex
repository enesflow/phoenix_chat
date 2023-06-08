defmodule QuickChat.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :members, {:array, :string}
    field :title, :string
    has_many :messages, QuickChat.Message
    has_many :users, through: [:messages, :user]

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:title, :members])
    |> validate_required([:members])
  end
end
