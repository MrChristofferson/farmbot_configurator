defmodule FarmbotConfigurator.Router do
  @moduledoc """
    Handles events from the static bundled web application.
  """
  alias FarmbotConfigurator.Plug.VerifyRequest
  use Plug.Router

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
  plug CORSPlug
  plug :match
  plug :dispatch

  post "/login" do
    GenServer.cast(FarmbotConfigurator.EventMan, {:event, {:login, conn.params}})
    conn
    |> send_resp(200, "Logging in.")
  end

  get "/" do
    headers = [{"location", "/index.html"}]
    conn
    |> merge_resp_headers(headers)
    |> send_resp(301, "redirect")
  end

  get "/scan" do
    GenServer.cast(FarmbotConfigurator.EventMan, {:event, {:scan, self()}})
    receive do
      {:ssids, list} -> send_resp(conn, 200, Poison.encode!(list))
      thing -> send_resp(conn, 500, "error: #{inspect thing}")
    after
      5000 -> send_resp(conn, 500, "error: timeout")
    end
  end

  get "/tea" do
    send_resp(conn, 418, "IM A TEAPOT")
  end

  match _ do
    send_resp(conn, 404, "Whatever you did could not be found.")
  end
end
