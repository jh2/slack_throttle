defmodule SlackThrottle.Queue do
  @moduledoc false

  require Logger
  alias SlackThrottle.Queue.{Supervisor, Worker}

  def enqueue_cast(token, fun) do
    enqueue_cast(token, Kernel, :apply, [fun, []])
  end

  def enqueue_cast(token, mod, fun, args) do
    q = get_or_create_queue(token)
    f = {mod, fun, args}
    Worker.enqueue_cast(q, f)
  end

  def enqueue_call(token, fun) do
    enqueue_call(token, Kernel, :apply, [fun, []])
  end

  def enqueue_call(token, mod, fun, args) do
    q = get_or_create_queue(token)
    f = {mod, fun, args}
    Worker.enqueue_call(q, f)
  end

  defp get_or_create_queue(token) do
    case Registry.lookup(SlackThrottle.Registry, token) do
      [] ->
        {:ok, queue} = Supervisor.start_queue(token)
        queue
      [{queue, _}] ->
        queue
    end
  end

end
