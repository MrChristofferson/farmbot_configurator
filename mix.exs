defmodule Farmbot.Configurator.Mixfile do
  use Mix.Project

  def project do
    [app: :farmbot_configurator,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [mod: {Farmbot.Configurator, []},
     applications: applications]
  end


  defp applications do
    [:logger,
     :plug,
     :cors_plug,
     :poison,
     :cowboy,
     :web_socket]
  end

  defp deps do
    [ {:plug, "~> 1.0"},
      {:cors_plug, "~> 1.1"},
      {:poison, "~> 3.0"},
      {:cowboy, "~> 1.0.0"},
      {:web_socket, github: "slogsdon/plug-web-socket"}
    ]
  end
end
