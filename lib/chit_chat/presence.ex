defmodule ChitChat.Presence do
  use Phoenix.Presence,
    otp_app: :chit_chat,
    pubsub_server: ChitChat.PubSub

  alias ChitChat.Accounts.User
  alias ChitChat.Repo
  import Ecto.Query

  def fetch(_topic, presences) do
    query =
      from u in User,
        where: u.id in ^Map.keys(Map.drop(presences, [""])),
        select: {u.id, u}

    users = query |> Repo.all() |> Enum.into(%{})

    for {key, %{metas: metas}} <- presences, into: %{} do
      int_key = force_int(key)

      user =
        case Map.has_key?(users, int_key) do
          true -> users[int_key]
          _ -> %{id: nil, username: "guest"}
        end

      {key,
       %{
         metas: metas,
         user: %{
           id: user.id,
           username: user.username
         }
       }}
    end
  end

  defp force_int(input) do
    case Integer.parse(input) do
      {n, _} -> n
      _ -> -1
    end
  end
end
