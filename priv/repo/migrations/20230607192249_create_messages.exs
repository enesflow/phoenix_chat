defmodule QuickChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :string

      add :user_id, references(:users)
      add :chat_id, references(:chats)

      timestamps()
    end
  end
end
