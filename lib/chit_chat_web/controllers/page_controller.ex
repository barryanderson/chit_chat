defmodule ChitChatWeb.PageController do
  use ChitChatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
