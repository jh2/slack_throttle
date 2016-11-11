defmodule Slack.Queue do
  require Logger

  @call_timeout Application.get_env(:slack, :enqueue_sync_timeout)

  def enqueue_cast(token, fun) do
    enqueue_cast(token, :erlang, :apply, [fun, []])
  end

  def enqueue_cast(token, mod, fun, args) do
    GenServer.cast(Slack.Queue.Registry, {:add, token, {mod, fun, args}})
  end

  def enqueue_call(token, fun) do
    enqueue_call(token, :erlang, :apply, [fun, []])
  end

  def enqueue_call(token, mod, fun, args) do
    GenServer.call(Slack.Queue.Registry, {:run, token, {mod, fun, args}},
      @call_timeout)
  end

end
