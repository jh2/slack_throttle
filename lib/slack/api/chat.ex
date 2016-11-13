defmodule Slack.API.Chat do

  def postMessage(token, %{channel: _channel} = params, type \\ :call) do
    # text = text
    # |> String.replace("&", "&amp")
    # |> String.replace("<", "&lt;")
    # |> String.replace(">", "&gt;")
    # params = %{params | :text => text}

    Slack.API.fetch(token, "chat.postMessage", params, type)
  end

end
