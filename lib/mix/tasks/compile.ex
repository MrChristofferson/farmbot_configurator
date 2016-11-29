defmodule Mix.Tasks.Compile.Configurator do
  use Mix.Task
  @moduledoc """
    Compiles Configurator JS and HTML
  """

  def run(_args) do
    # IO.puts "Running `npm install`"
    # System.cmd("npm", ["install"])
    IO.puts "complete. Building."
    System.cmd("npm", ["run", "build"])
  end
end

defmodule Mix.Tasks.Clean.Configurator do
  use Mix.Task
  @moduledoc """
    Cleans compiled stuff
  """

  def run(_args) do
    IO.puts "sorry..."
  end
end
