defmodule Slack.Queue.Registry do
  use GenServer
  alias Slack.Queue.{Supervisor, Worker}
  require Logger

  @call_timeout Application.get_env(:slack, :enqueue_sync_timeout)

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  # unused, see Lunch.Queue
  def enqueue_cast(server, token, fun) do
    enqueue_cast(server, token, :erlang, :apply, [fun, []])
  end

  # unused
  def enqueue_cast(server, token, mod, fun, args) do
    GenServer.cast(server, {:add, token, {mod, fun, args}})
  end

  # unused
  def enqueue_call(server, token, fun) do
    enqueue_call(server, token, :erlang, :apply, [fun, []])
  end

  # unused
  def enqueue_call(server, token, mod, fun, args) do
    GenServer.call(server, {:run, token, {mod, fun, args}}, @call_timeout)
  end


  def init(:ok) do
    {:ok, {%{}, %{}}}
  end

  def handle_call({:run, token, fun}, _from, {queues, refs}) do
    {q, qs, refs} = get_or_create_queue(token, queues, refs)
    res = Worker.enqueue_call(q, fun)
    {:reply, res, {qs, refs}}
  end

  def handle_cast({:add, token, fun}, {queues, refs}) do
    {q, qs, refs} = get_or_create_queue(token, queues, refs)
    Worker.enqueue_cast(q, fun)
    {:noreply, {qs, refs}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {queues, refs}) do
    Logger.debug "handle_info down"
    {token, refs} = Map.pop(refs, ref)
    queues = Map.delete(queues, token)
    {:noreply, {queues, refs}}
  end

  def handle_info(msg, state) do
    Logger.debug "handle_info #{inspect msg}"
    {:noreply, state}
  end

  defp get_or_create_queue(token, queues, refs) do
    if Map.has_key?(queues, token) do
      q = Map.fetch!(queues, token)
      Logger.debug "found running queue proccess for token #{token}"
      {q, queues, refs}
    else
      {:ok, q} = Supervisor.start_queue
      ref = Process.monitor(q)
      refs = Map.put(refs, ref, token)
      Logger.debug "creating new queue proccess for token #{token}"
      qs = Map.put(queues, token, q)
      {q, qs, refs}
    end
  end

end