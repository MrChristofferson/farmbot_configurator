defmodule Farmbot.Configurator.EventMan do
  @moduledoc """
    Forwards events to the givin event manager.
  """
  use GenServer
  require Logger

  def init(handler) do
    {:ok, manager} = GenEvent.start_link
    GenEvent.add_handler(manager, handler, self())
    {:ok, manager}
  end

  def start_link(handler) do
    GenServer.start_link(__MODULE__, handler, name: __MODULE__)
  end

  def handle_cast({:event, event}, manager) do
    GenEvent.notify(manager, event)
    {:noreply, manager}
  end
end

defmodule Farmbot.Configurator.EventHan do
  @moduledoc """
    A example event handler for Farmbot.Configurator.
  """
  use GenEvent
  require Logger

  def handle_event({:scan, pid}, parent) do
    send(pid, {:ssids, ["not", "on", "real", "hardware"]})
    {:ok, parent}
  end

  def handle_event(event, parent) do
    Logger.debug("#{inspect event}")
    {:ok, parent}
  end
end
