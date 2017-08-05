defmodule SlackThrottle.Mixfile do
  use Mix.Project

  def project do
    [app: :slack_throttle,
     version: "0.2.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: {SlackThrottle, []},
     env: [api_throttle: 1000, enqueue_sync_timeout: 20000]]
  end

  defp description do
    """
    Slack Web API wrapper library that automatically throttles all requests
    according to API rate limits.
    """
  end

  defp package do
    [name: :slack_throttle,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Johannes Hofmann"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/jh2/slack_throttle"}]
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
