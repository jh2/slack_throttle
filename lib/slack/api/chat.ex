defmodule Slack.API.Chat do

  def postMessage(token, [channel: _channel, text: text] = params, type \\ :call) do
    text = text
    |> String.replace("&", "&amp")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    Keyword.put(params, :text, text)

    Slack.API.fetch(token, "chat.postMessage", params, type)
  end

end
