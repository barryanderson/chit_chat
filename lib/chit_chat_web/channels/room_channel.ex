defmodule ChitChatWeb.RoomChannel do
  use ChitChatWeb, :channel
  alias ChitChat.Accounts

  def join("rooms:" <> room_id, _payload, socket) do
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
end
