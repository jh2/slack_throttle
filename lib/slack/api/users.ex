defmodule Slack.API.Users do

  def getPresence(token, [user: _user] = params, type \\ :call) do
    Slack.API.fetch(token, "users.getPresence", params, type)
  end

  def list(token, params \\ [], type \\ :call) do
    Slack.API.fetch(token, "users.list", params, type)
  end

  def info(token, [user: _user] = params, type \\ :call) do
    Slack.API.fetch(token, "users.info", params, type)
  end

end
