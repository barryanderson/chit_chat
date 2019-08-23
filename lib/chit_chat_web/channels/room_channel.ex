defmodule ChitChatWeb.RoomChannel do
  use ChitChatWeb, :channel
  alias ChitChat.{Accounts, Presence}

  def join("rooms:" <> room_id, _payload, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :room_id, String.to_integer(room_id))}
  end

  def handle_in(event, payload, socket = %{assigns: %{user_id: uid}}) do
    user =
      case uid do
        x when is_integer(x) -> Accounts.get_user!(uid)
        _ -> nil
      end

    handle_in(event, payload, user, socket)
  end

  def handle_in("new_chat", payload, user, socket) do
    broadcast!(socket, "new_chat", %{
      username: if(user, do: user.username, else: "guest"),
      body: payload["body"]
    })

    {:reply, :ok, socket}
  end

  def handle_info(:after_join, socket) do
    pres = Presence.list(socket)
    push(socket, "presence_state", pres)
    guests = if Map.has_key?(pres, ""), do: pres[""].metas, else: []
    num_guests = Enum.count(guests)
    users = Enum.filter(pres, fn {k, _} -> k =~ ~r/^\d+$/ end)
    num_users = Enum.count(users)

    IO.puts("Presence info #{inspect(pres)}")
    IO.puts("Users: #{num_users}, Guests: #{num_guests}")

    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        online_at: System.system_time(:second)
      })

    {:noreply, socket}
  end
end
