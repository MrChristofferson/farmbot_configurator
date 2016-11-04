defmodule NetworkSupervisor do
  require Logger
  use Supervisor
  def init(env) do
    children = [ worker(NetMan, [env], restart: :permanent) ]
    opts = [strategy: :one_for_all, name: __MODULE__]
    supervise(children, opts)
  end

  def start_link(env) do
    Logger.debug("Starting Network")
    Supervisor.start_link(__MODULE__, env)
  end
end
