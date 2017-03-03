defmodule SlackThrottle.Mixfile do
  use Mix.Project

  def project do
    [app: :slack_throttle,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: {SlackThrottle, []},
     env: [api_throttle: 1000, enqueue_sync_timeout: 20000]]
  end

  defp deps do
    [
      {:poison, "~> 2.0"},
      {:httpoison, "~> 0.10.0"},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end
end
