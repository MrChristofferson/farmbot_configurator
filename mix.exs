defmodule Farmbot.Configurator.Mixfile do
  use Mix.Project

  def project do
    [app: :farmbot_configurator,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(System.get_env("MIX_ENV") || Mix.env)]
  end

  def application do
    [mod: {Farmbot.Configurator, []},
     applications: applications(System.get_env("MIX_ENV") || Mix.env)]
  end

  defp applications("prod"), do: applications(:prod)
  defp applications(:prod) do
    [:logger,
     :plug,
     :cors_plug,
     :poison,
     :cowboy,
     :nerves_networking,
     :nerves_interim_wifi]
  end

  defp applications("dev"), do: applications(:dev)
  defp applications("test"), do: applications(:dev)
  defp applications(:dev) do
    [:logger,
     :plug,
     :cors_plug,
     :poison,
     :cowboy]
  end

  defp deps("prod"), do: deps(:prod)
  defp deps(:prod) do
    [ {:plug, "~> 1.0"},
      {:cors_plug, "~> 1.1"},
      {:poison, "~> 2.0"},
      {:cowboy, "~> 1.0.0"},
      {:nerves_networking, github: "nerves-project/nerves_networking"},
      {:nerves_interim_wifi, github: "nerves-project/nerves_interim_wifi"}]
  end

  defp deps(_) do
    [ {:plug, "~> 1.0"},
      {:cors_plug, "~> 1.1"},
      {:poison, "~> 2.0"},
      {:cowboy, "~> 1.0.0"},
      {:fake_nerves, github: "ConnorRigby/fake_nerves"}]
  end
end
