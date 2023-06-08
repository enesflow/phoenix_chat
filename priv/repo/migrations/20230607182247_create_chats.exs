defmodule QuickChat.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :members, {:array, :string}
      add :title, :string

      timestamps()
    end
  end
end
