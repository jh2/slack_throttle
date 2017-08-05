defmodule SlackThrottle.Queue.Supervisor do
  @moduledoc false

  use Supervisor

  @name SlackThrottle.Queue.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_queue(token) do
    Supervisor.start_child(@name, [token])
  end

  def init(:ok) do
    children = [
      worker(SlackThrottle.Queue.Worker, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
