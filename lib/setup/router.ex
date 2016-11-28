defmodule Farmbot.Configurator.Router do
  @cb Application.get_env(:farmbot_configurator, :callback)
  @moduledoc """
    Handles events from the static bundled web application.
  """
  alias Farmbot.Configurator.Plug.VerifyRequest
  use Plug.Router
  require IEx
  plug CORSPlug

  plug Plug.Parsers, parsers: [:urlencoded, :json],
                     pass:  ["text/*"],
                     json_decoder: Poison

  plug VerifyRequest, fields: ["email",
                               "password",
                               "network",
                               "server",
                               "tz"],
                      paths:  ["/login"]

  plug Plug.Static, at: "/", from: :farmbot_configurator
  plug :match
  plug :dispatch


  post "/login" do
    GenServer.cast(@cb, {:login, conn.params})
    conn
    |> send_resp(200, "Logging in.")
  end

  get "/" do
    headers = [{"location", "/index.html"}]
    conn
    |> merge_resp_headers(headers)
    |> send_resp(301, "redirect")
  end

  get "/info" do
    conn
    |> send_resp(200, Poison.encode!(%{name: Node.self}))
  end

  get "/secret" do
    headers = [{"location", "/secret.html"}]
    conn
    |> merge_resp_headers(headers)
    |> send_resp(301, "redirect")
  end

  get "/scan" do
    send_resp(conn, 200, Poison.encode!(NetMan.scan))
  end

  get "/tea" do
    send_resp(conn, 418, "IM A TEAPOT")
  end

  match _ do
    send_resp(conn, 404, "Whatever you did could not be found.")
  end
end
