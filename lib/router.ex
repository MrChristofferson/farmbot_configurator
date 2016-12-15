defmodule Farmbot.Configurator.Router do
  use Plug.Router
  use WebSocket


  plug :match
  plug :dispatch

  socket "/ws", Farmbot.Configurator.WSHandler, :handle
  match _ do
    conn |> send_resp(404, "Not Found")
  end
end
