defmodule NetworkSupervisor do
  require Logger
  use Supervisor
  @env Mix.env

  def init(_args) do
    children = [ worker(NetMan, [[]], restart: :permanent) ]
    opts = [strategy: :one_for_all, name: __MODULE__]
    supervise(children, opts)
  end

  def start_link(args) do
    Logger.debug("Starting Network")
    Supervisor.start_link(__MODULE__, args)
  end
end
