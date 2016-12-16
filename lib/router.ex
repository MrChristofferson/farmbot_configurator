defmodule Farmbot.Configurator.Router do
  use Plug.Router
  use WebSocket



  plug Plug.Static, at: "/", from: :farmbot_configurator
  plug :match
  plug :dispatch

  socket "/ws", Farmbot.Configurator.WSHandler, :handle
  match _ do
    conn |> send_resp(200, make_html)
  end

  def make_html do
    "#{:code.priv_dir(:farmbot_configurator)}/static/index.html"
    |> File.read!
  end
end
