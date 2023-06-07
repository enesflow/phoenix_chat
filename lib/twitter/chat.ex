defmodule Twitter.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :members, {:array, :string}
    has_many :messages, Twitter.Message
    has_many :users, through: [:messages, :user]

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:members])
    |> validate_required([:members])
  end
end
