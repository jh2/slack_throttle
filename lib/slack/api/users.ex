defmodule Slack.API.Users do

  def getPresence(token, [user: _user] = params, type \\ :call) do
    Slack.API.fetch(token, "users.getPresence", params, type)
  end

end
