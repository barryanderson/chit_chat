defmodule ChitChat.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias Argon2

  schema "rooms" do
    field :description, :string
    field :name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    belongs_to :user, ChitChat.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description, :password, :password_confirmation])
    |> validate_required([:name, :description])
    |> unique_constraint(:name)
    |> validate_length(:password, min: 4)
    |> validate_confirmation(:password)
    |> hash_password()
  end

  defp hash_password(%{valid?: false} = changeset), do: changeset

  defp hash_password(%{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
  end

  defp hash_password(%{valid?: true} = changeset), do: changeset
end
