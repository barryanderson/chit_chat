defmodule ChitChat.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string
      add :description, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:rooms, [:name])
    create index(:rooms, [:user_id])
  end
end
