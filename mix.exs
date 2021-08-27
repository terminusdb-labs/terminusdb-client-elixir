defmodule TerminusDBClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :terminusdb_client,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:jaxon, "~> 2.0"}
    ]
  end
end
