defmodule FarmbotConfigurator do
  require Logger
  use Supervisor
  @env Mix.env
  @handler Application.get_env(:farmbot_configurator, :event_handler)
  def init(:prod) do
    children = [
      worker(FarmbotConfigurator.EventMan, [@handler], [restart: :permanent]),
      Plug.Adapters.Cowboy.child_spec(:http, FarmbotConfigurator.Router, [restart: :permanent], [port: 80])
    ]
    opts = [strategy: :one_for_one, name: FarmbotConfigurator]
    supervise(children, opts)
  end

  def init(:dev) do
    children = [
      worker(FarmbotConfigurator.EventMan, [@handler], [restart: :permanent]),
      Plug.Adapters.Cowboy.child_spec(:http, FarmbotConfigurator.Router, [restart: :permanent], [port: 4000])
    ]
    opts = [strategy: :one_for_one, name: FarmbotConfigurator]
    supervise(children, opts)
  end

  def start(_type, _args) do
    Supervisor.start_link( __MODULE__, @env )
  end
end
