defmodule Slack.API.Channels do

  def info(token, [channel: _channel] = params, type \\ :call) do
    Slack.API.fetch(token, "channels.info", params, type)
  end

end
