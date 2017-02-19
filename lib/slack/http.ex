defmodule Slack.HTTP do
  @moduledoc false

  use HTTPoison.Base

  def fetch(token, method, params, :call) do
    params = params
    |> Map.to_list
    |> Keyword.put(:token, token)

    res = Slack.Queue.enqueue_call(
      token,
      __MODULE__, :get!, [method, headers, [params: params]]
    )
    res.body
  end
  def fetch(token, method, params, :cast) do
    params = params
    |> Map.to_list
    |> Keyword.put(:token, token)

    Slack.Queue.enqueue_cast(
      token,
      __MODULE__, :get!, [method, headers, [params: params]]
    )
  end

  def process_url(url) do
    "https://api.slack.com/api/#{url}"
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
  end

  def headers do
    %{
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

end
