defmodule Slack.API.OAuth do

  def access(%{client_id: _, client_secret: _, code: _} = params) do
    params = Map.to_list(params)
    Slack.API.get!("oauth.access", Slack.API.headers, [params: params])
  end

end
