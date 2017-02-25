defmodule Slack.Queue do
  @moduledoc false

  require Logger
  alias Slack.Queue.Registry

  def enqueue_cast(token, fun) do
    enqueue_cast(token, Kernel, :apply, [fun, []])
  end

  def enqueue_cast(token, mod, fun, args) do
    Registry.enqueue_cast(Registry, token, mod, fun, args)
  end

  def enqueue_call(token, fun) do
    enqueue_call(token, Kernel, :apply, [fun, []])
  end

  def enqueue_call(token, mod, fun, args) do
    Registry.enqueue_call(Registry, token, mod, fun, args)
  end

end
