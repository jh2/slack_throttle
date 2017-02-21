defmodule Slack.API do
  @moduledoc """
  This library provides wrapper functions for requests to the Slack Web API and
  takes care of rate limits for you.

  ## Usage

  Look up the API method you want to use in the
  [Slack documentation](https://api.slack.com/methods). Function names are
  method names with dots replaced by underscores:

      # method: channels.info
      iex> SlackApp.API.channels_info("some token", %{channel: "C123456"})
      %{"ok" => true, "channel" => %{"id" => "C123456", ...}}

  > Replacing dots by underscores is actually exactly what the compiler does.
  > By the magic of meta programming all these functions are created
  > dynamically.

  If you don't care about the response, e.g. when broadcasting a message,
  use `:cast` as the third argument:

      # method: chat.postMessage
      iex> SlackApp.API.chat_postMessage("some token", params, :cast)
      :ok

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

      config :slack_app,
        api_throttle: 1000, # in milliseconds
        enqueue_sync_timeout: 20000 # in milliseconds



  """

  [
    "auth.revoke",
    "auth.test",

    "bots.info",

    "channels.archive",
    "channels.close",
    "channels.create",
    "channels.createChild",
    "channels.history",
    "channels.info",
    "channels.invite",
    "channels.kick",
    "channels.leave",
    "channels.list",
    "channels.mark",
    "channels.open",
    "channels.rename",
    "channels.replies",
    "channels.setPurpose",
    "channels.setTopic",
    "channels.unarchive",

    "chat.delete",
    "chat.meMessage",
    "chat.postMessage",
    "chat.update",

    "dnd.info",
    "dnd.teamInfo",

    "emoji.list",

    "files.comments.add",
    "files.comments.delete",
    "files.comments.edit",

    "files.delete",
    "files.info",
    "files.list",
    "files.revokePublicURL",
    "files.sharedPublicURL",
    "files.upload",

    "groups.archive",
    "groups.close",
    "groups.create",
    "groups.createChild",
    "groups.history",
    "groups.info",
    "groups.invite",
    "groups.kick",
    "groups.leave",
    "groups.list",
    "groups.mark",
    "groups.open",
    "groups.rename",
    "groups.replies",
    "groups.setPurpose",
    "groups.setTopic",
    "groups.unarchive",

    "im.close",
    "im.history",
    "im.list",
    "im.mark",
    "im.open",
    "im.replies",

    "mpim.close",
    "mpim.history",
    "mpim.list",
    "mpim.mark",
    "mpim.open",
    "mpim.replies",

    "pins.add",
    "pins.list",
    "pins.remove",

    "reactions.add",
    "reactions.get",
    "reactions.list",
    "reactions.remove",

    "reminders.add",
    "reminders.complete",
    "reminders.delete",
    "reminders.info",
    "reminders.list",

    "rtm.start",

    "search.all",
    "search.files",
    "search.messages",

    "stars.add",
    "stars.list",
    "stars.remove",

    "team.accessLogs",
    "team.billableInfo",
    "team.info",
    "team.integrationLogs",

    "team.profile.get",

    "usergroups.create",
    "usergroups.disable",
    "usergroups.enable",
    "usergroups.list",
    "usergroups.update",

    "usergroups.users.list",
    "usergroups.users.update",

    "users.deletePhoto",
    "users.getPresence",
    "users.identity",
    "users.info",
    "users.list",
    "users.setActive",
    "users.setPhoto",
    "users.setPresence",

    "users.profile.get",
    "users.profile.set",
  ]
  |> Enum.each(fn method ->
    fun = method |> String.replace(".", "_") |> String.to_atom
    @doc """
    [#{method}](https://api.slack.com/methods/#{method})
    """
    @spec unquote(fun)(binary, %{atom => any}, :call | :cast) ::
      %{binary => any} | :ok
    def unquote(fun)(token, params \\ %{}, type \\ :call) do
      Slack.HTTP.fetch(token, unquote(method), params, type)
    end
  end)


  [
    "api.test",
    "oauth.access"
  ]
  |> Enum.each(fn method ->
    fun = method |> String.replace(".", "_") |> String.to_atom
    @doc """
    [#{method}](https://api.slack.com/methods/#{method})
    """
    @spec unquote(fun)(%{atom => any}) :: %{binary => any}
    def unquote(fun)(params \\ %{}) do
      params = Map.to_list(params)
      res = Slack.HTTP.get!(unquote(method), Slack.HTTP.headers,
        [params: params])
      res.body
    end
  end)


end
