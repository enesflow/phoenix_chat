defmodule Twitter.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :members, {:array, :string}

      timestamps()
    end
  end
end
