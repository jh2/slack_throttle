defmodule Slack.Queue.Registry do
  use GenServer
  alias Slack.Queue.{Supervisor, Worker}
  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def enqueue(server, token, fun) do
    enqueue(server, token, :erlang, :apply, [fun, []])
  end

  def enqueue(server, token, mod, fun, args) do
    GenServer.cast(server, {:add, token, {mod, fun, args}})
  end

  def enqueue_sync(server, token, fun) do
    enqueue_sync(server, token, :erlang, :apply, [fun, []])
  end

  def enqueue_sync(server, token, mod, fun, args) do
    GenServer.call(server, {:run, token, {mod, fun, args}},
      Application.get_env(:slack, :enqueue_sync_timeout))
  end

  def halt(server, token) do
    GenServer.cast(server, {:halt, token})
  end


  def init(:ok) do
    {:ok, {%{}, %{}}}
  end

  def handle_call({:run, token, fun}, _from, {queues, refs}) do
    {q, qs, refs} = get_or_create_queue(token, queues, refs)
    res = Worker.enqueue_sync(q, fun)
    {:reply, res, {qs, refs}}
  end

  def handle_cast({:add, token, fun}, {queues, refs}) do
    {q, qs, refs} = get_or_create_queue(token, queues, refs)
    Worker.enqueue(q, fun)
    {:noreply, {qs, refs}}
  end

  def handle_cast({:halt, token}, {queues, refs}) do
    {q, qs, refs} = get_or_create_queue(token, queues, refs)
    Logger.info "killing process #{inspect q}"
    Process.exit(q, :kill)
    {:noreply, {qs, refs}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {queues, refs}) do
    IO.puts("handle_info down")
    {token, refs} = Map.pop(refs, ref)
    queues = Map.delete(queues, token)
    {:noreply, {queues, refs}}
  end

  def handle_info(msg, state) do
    IO.puts("handle_info #{inspect msg}")
    {:noreply, state}
  end

  defp get_or_create_queue(token, queues, refs) do
    if Map.has_key?(queues, token) do
      q = Map.fetch!(queues, token)
      Logger.info "found running queue proccess for token #{token}"
      {q, queues, refs}
    else
      {:ok, q} = Supervisor.start_queue
      ref = Process.monitor(q)
      refs = Map.put(refs, ref, token)
      Logger.info "creating new queue proccess for token #{token}"
      qs = Map.put(queues, token, q)
      {q, qs, refs}
    end
  end

end
