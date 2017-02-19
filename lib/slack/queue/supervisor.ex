defmodule Slack.Queue.Supervisor do
  @moduledoc false

  use Supervisor

  @name Slack.Queue.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_queue do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      worker(Slack.Queue.Worker, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
