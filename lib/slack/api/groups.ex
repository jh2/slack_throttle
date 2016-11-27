defmodule Slack.API.Groups do

  def info(token, %{channel: _channel} = params, type \\ :call) do
    Slack.API.fetch(token, "groups.info", params, type)
  end

end
