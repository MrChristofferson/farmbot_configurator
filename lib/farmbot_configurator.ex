defmodule Farmbot.Configurator do
  use Supervisor
  alias Plug.Adapters.Cowboy
  alias Farmbot.Configurator.Router
  @port Application.get_env(:configurator, :port, 4000)

  def init(_) do
    # children = [
    #   Cowboy.child_spec(:http, Router, [restart: :permanent], [
    #       port: @port,
    #       dispatch: dispatch
    #   ])
    # ]
    children = [
       Plug.Adapters.Cowboy.child_spec(:http, Router, [], port: @port, dispatch: Router.dispatch_table)
     ]
    opts = [strategy: :one_for_one, name: Farmbot.Configurator]
    supervise(children, opts)
  end

  def start(_type, args) do
    Supervisor.start_link(__MODULE__,args)
  end

  # defp dispatch do
  # [
  #   {:_, [
  #     {"/ws", Farmbot.Configurator.SocketHandler, []},
  #     {:_, Plug.Adapters.Cowboy.Handler, {Router, []}}
  #   ]}
  # ]
  # end
end
