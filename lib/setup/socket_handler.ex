defmodule Farmbot.Configurator.SocketHandler do
  @behaviour :cowboy_websocket_handler

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @timeout 60000 # terminate if no activity for one minute

  #Called on websocket connection initialization.
  def websocket_init(_type, req, _opts) do
    {:ok, pid} = Comms.start_link(self())
    state = pid
    {:ok, req, state, @timeout}
  end

  # Handle 'ping' messages from the browser - reply
  def websocket_handle({:text, "ping"}, req, state) do
    {:reply, {:text, "pong"}, req, state}
  end

  # Handle other messages from the browser - don't reply
  def websocket_handle({:text, message}, req, state) do
    Comms.do_thing(message)
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

defmodule Comms do
  use GenServer
  def start_link(pid) do
    GenServer.start_link(__MODULE__, pid, name: __MODULE__)
  end
  def init(pid) do
    {:ok, pid}
  end

  def handle_info({:send, msg}, pid) do
    send(pid, msg)
    {:noreply, pid}
  end

  def send(msg) do
    send Comms, {:send, msg}
  end

  def do_thing(message) do
    with {:ok, f} <- Code.string_to_quoted(String.strip(message)),
          {output, _} <- Code.eval_quoted(f),
          do: send(output)
  end
end
