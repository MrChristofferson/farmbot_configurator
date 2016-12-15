defmodule Farmbot.Configurator.SocketHandler do
  @behaviour :cowboy_websocket_handler
  @timeout 60000 # terminate if no activity for one minute
  require Logger

  def init(_, _req, _opts), do: {:upgrade, :protocol, :cowboy_websocket}

  #Called on websocket connection initialization.
  def websocket_init(_type, req, _opts) do
    {:ok, req, [], @timeout}
  end

  def websocket_handle({:text, "test"}, req, state) do
    {:ok, req, state}
  end

  def websocket_handle({:text, "test1"}, req, state) do
    {:reply, {:text, "testret"}, req, state}
  end

  # Handle other messages from the browser - don't reply
  def websocket_handle({:text, message}, req, state) do
    Logger.debug "got a ws message: #{inspect message}"
    {:ok, req, state}
  end

  def websocket_handle({:ping, _}, req, state) do
    {:reply, {:pong, ""}, req, state}
  end

  # Format and forward elixir messages to client
  def websocket_info(message, req, state) do
    Logger.debug "got a info message: #{inspect message}"
    {:reply, {:text, "#{inspect message}"}, req, state}
  end

  # No matter why we terminate, remove all of this pids subscriptions
  def websocket_terminate(_reason, _req, pid) do
    GenServer.stop(pid, :normal)
  end
end
