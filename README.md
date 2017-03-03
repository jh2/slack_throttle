# SlackThrottle

Slack Web API wrapper library that automatically throttles all requests according to API rate limits.

[hexdocs](https://hexdocs.pm/slack_throttle)

## Installation

Add `slack_throttle` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:slack_throttle, "~> 0.2.0"}]
end
```

Ensure `slack_throttle` is started before your application:

```elixir
def application do
  [applications: [:slack_throttle]]
end
```

## Usage

Look up the API method you want to use in the
[Slack documentation](https://api.slack.com/methods). Function names are
method names with dots replaced by underscores:

```elixir
# method: channels.info
iex> SlackThrottle.API.channels_info("some token", %{channel: "C123456"})
%{"ok" => true, "channel" => %{"id" => "C123456", ...}}
```

If you don't care about the response, e.g. when broadcasting a message,
use `:cast` as the third argument:

```elixir
# method: chat.postMessage
iex> SlackThrottle.API.chat_postMessage("some token", params, :cast)
:ok
```

Broadcasts are executed asynchronously and return `:ok` immediately.

## Rate Limits

The Slack Web API is subject to
[rate limiting](https://api.slack.com/docs/rate-limits).  Requests are only
allowed at a rate of one per second on a per-access-token basis.

To comply with these restrictions, the library queues all function calls
(grouped by access token) and executes them at the given rate.  These queues
are priority queues: Regular blocking function calls have higher priority than
asynchronous broadcasts (the `:cast` ones).

## Configuration

The API throttle rate `:api_throttle` can be configured as well as the
timeout for blocking function calls `:enqueue_sync_timeout`:

```elixir
config :slack_throttle,
  api_throttle: 1000, # in milliseconds
  enqueue_sync_timeout: 20000 # in milliseconds
```

## Built for and used by

[lunchorder](https://lunch.cjh.io), a lunch order list making Slack app

## License

MIT
