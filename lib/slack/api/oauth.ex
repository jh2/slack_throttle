defmodule Slack.API.OAuth do

  def access(%{client_id: _, client_secret: _, code: _} = params) do
    params = Map.to_list(params)
    res = Slack.API.get!("oauth.access", Slack.API.headers, [params: params])
    res.body
  end

end
