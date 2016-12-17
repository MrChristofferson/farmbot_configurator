defmodule Farmbot.Configurator do
  use Supervisor
  alias Plug.Adapters.Cowboy
  alias Farmbot.Configurator.Router
  alias Farmbot.Configurator.EventHandler
  alias Farmbot.Configurator.EventManager
  @port Application.get_env(:configurator, :port, 4000)
  @env Mix.env

  def init(_) do
    children = [
      # genevent manager for the handler to connect to.
      # worker(GenEvent,
      #   [[name: EventManager]],
      #    [id: EventManager]),
      worker(EventManager, [], []),
      worker(EventHandler, [], []),
      Plug.Adapters.Cowboy.child_spec(
        :http, Router, [], port: @port, dispatch: dispatch),
      worker(WebPack, [@env])
     ]
    opts = [strategy: :one_for_one, name: Farmbot.Configurator]
    supervise(children, opts)
  end

  def start(_type, args), do: Supervisor.start_link(__MODULE__,args)

  defp dispatch do
  [
    {:_, [
      {"/ws", Farmbot.Configurator.SocketHandler, []},
      {:_, Plug.Adapters.Cowboy.Handler, {Router, []}}
    ]}
  ]
  end
end
