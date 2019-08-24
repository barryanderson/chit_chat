defmodule ChitChat.Repo.Migrations.AddPrivateRoomInfo do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :password_hash, :text
    end
  end
end
