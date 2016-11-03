defmodule FarmbotConfigurator.Mixfile do
  use Mix.Project

  def project do
    [app: :farmbot_configurator,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [mod: {FarmbotConfigurator, []},
     applications: [
      :logger,
      :plug,
      :cors_plug,
      :poison,
      :cowboy ]]
  end

  defp deps do
    [ {:plug, "~> 1.0"},
      {:cors_plug, "~> 1.1"},
      {:poison, "~> 2.0"},
      {:cowboy, "~> 1.0.0"}]
  end
end
