defmodule Farmbot.Configurator do
  require Logger
  use Supervisor
  @env Mix.env
  @handler Application.get_env(:farmbot_configurator, :event_handler)
  def init(:prod) do
    children = [
      supervisor(NetworkSupervisor, [@env], restart: :permanent),
      worker(Farmbot.Configurator.EventMan, [@handler], [restart: :permanent]),
      Plug.Adapters.Cowboy.child_spec(:http, Farmbot.Configurator.Router, [restart: :permanent], [
          port: 80,
          dispatch: dispatch
      ])
    ]
    opts = [strategy: :one_for_one, name: Farmbot.Configurator]
    supervise(children, opts)
  end

  def init(:dev) do
    children = [
      supervisor(NetworkSupervisor, [@env], restart: :permanent),
      worker(Farmbot.Configurator.EventMan, [@handler], [restart: :permanent]),
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
