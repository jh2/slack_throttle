defmodule Slack.API do
  use HTTPoison.Base

  def test(token, params \\ [], type \\ :call) do
    fetch(token, "api.test", params, type)
  end

  def test2 do
    "test2"
  end


  def fetch(token, method, params, :call) do
    params = Keyword.put(params, :token, token)
    res = Slack.Queue.enqueue_call(
      token,
      __MODULE__, :get!, [method, headers, [params: params]]
    )
    res.body
  end
  def fetch(token, method, params, :cast) do
    params = Keyword.put(params, :token, token)
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
