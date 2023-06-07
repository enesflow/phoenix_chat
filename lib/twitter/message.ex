defmodule Twitter.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :body, :string

    belongs_to :user, Twitter.User
    belongs_to :chat, Twitter.Chat

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
