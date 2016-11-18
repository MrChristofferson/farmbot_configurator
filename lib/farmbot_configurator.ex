defmodule Farmbot.Configurator do
  require Logger
  use Supervisor
  @env System.get_env("MIX_ENV") || Mix.env
  IO.inspect(@env)
  def init("prod"), do: init(:prod)
  def init(:prod) do
    children = [
      supervisor(NetworkSupervisor, [@env], restart: :permanent),
      Plug.Adapters.Cowboy.child_spec(:http, Farmbot.Configurator.Router, [restart: :permanent], [
          port: 80,
          dispatch: dispatch
      ])
    ]
    opts = [strategy: :one_for_one, name: Farmbot.Configurator]
    supervise(children, opts)
  end

  def init(_) do
    children = [
      supervisor(NetworkSupervisor, [@env], restart: :permanent),
      Plug.Adapters.Cowboy.child_spec(:http, Farmbot.Configurator.Router, [restart: :permanent], [
          port: 4000,
          dispatch: dispatch
      ])
    ]
    opts = [strategy: :one_for_one, name: Farmbot.Configurator]
    supervise(children, opts)
  end

  def start(_type, _args) do
    Supervisor.start_link( __MODULE__, @env )
  end

  defp dispatch() do
  [
    {:_, [
      {"/ws", Farmbot.Configurator.SocketHandler, []},
      {:_, Plug.Adapters.Cowboy.Handler, {Farmbot.Configurator.Router, []}}
    ]}
  ]
  end
end
