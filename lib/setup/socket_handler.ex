defmodule Farmbot.Configurator.SocketHandler do
  @behaviour :cowboy_websocket_handler

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @timeout 60000 # terminate if no activity for one minute

  #Called on websocket connection initialization.
  def websocket_init(_type, req, _opts) do
    {:ok, pid} = Blah.start_link(self())
    state = pid
    {:ok, req, state, @timeout}
  end

  # Handle 'ping' messages from the browser - reply
  def websocket_handle({:text, "ping"}, req, state) do
    {:reply, {:text, "pong"}, req, state}
  end

  # Handle other messages from the browser - don't reply
  def websocket_handle({:text, message}, req, state) do
    Blah.do_thing(message)
    {:ok, req, state}
  end

  # Format and forward elixir messages to client
  def websocket_info(message, req, state) do
    {:reply, {:text, "#{inspect message}"}, req, state}
  end

  # No matter why we terminate, remove all of this pids subscriptions
  def websocket_terminate(_reason, _req, pid) do
    GenServer.stop(pid, :normal)
  end
end

defmodule Blah do
  use GenServer
  require Logger
  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, state}
  end

  def do_thing(thing) do
    Logger.warn ("#{__MODULE__}: Unhandled thing: #{inspect thing}")
  end

  def handle_cast({:send, stuff}, socket) do
    send socket, stuff
    {:noreply, socket}
  end

  def send(stuff) do
    GenServer.cast(__MODULE__, {:send, stuff})
  end
end
