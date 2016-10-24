defmodule FarmbotConfigurator do
  require Logger
  use Supervisor
  def init(:prod) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, FarmbotRouter, [restart: :permanent], [port: 80])
    ]
    opts = [strategy: :one_for_one, name: FarmbotConfigurator]
    supervise(children, opts)
  end

  def init(:dev) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, FarmbotRouter, [restart: :permanent], [port: 4000])
    ]
    opts = [strategy: :one_for_one, name: FarmbotConfigurator]
    supervise(children, opts)
  end

  def start(_type, _args) do
    Supervisor.start_link(__MODULE__, Mix.env)
  end
end
