defmodule Slack.API do
  use HTTPoison.Base
  alias Slack.Queue.Registry

  def fetch(method, token, params) do
    params = Keyword.put(params, :token, token)
    res = Registry.enqueue_sync(
      Registry, token,
      __MODULE__, :get!, [method, headers, [params: params]]
    )
    res.body
  end

  def process_url(url) do
    "https://api.slack.com/api/#{url}"
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Enum.map(fn ({k, v}) -> {String.to_atom(k), v} end)
  end

  def headers do
    %{
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

end
