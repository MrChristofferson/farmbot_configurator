defmodule Farmbot.Configurator.WSHandler do
  def handle(:init, state) do
    {:ok, state}
  end

  def handle(:terminate, _state) do
    :ok
  end

  def handle(thing, state) do
    IO.inspect thing
    {:reply, {:text, thing}, state}
  end
end
