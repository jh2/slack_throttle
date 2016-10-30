defmodule Slack.Queue.Worker do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def enqueue(server, fun) do
    res = GenServer.cast(server, {:add, fun})
    GenServer.cast(server, {:suspend, nil})
    res
  end

  def enqueue_sync(server, fun) do
    res = GenServer.call(server, {:run, fun},
      Application.get_env(:slack, :enqueue_sync_timeout))
    GenServer.cast(server, {:suspend, nil})
    res
  end



  def init(:ok) do
    {:ok, :ok}
  end

  def handle_call({:run, {mod, fun, args}}, _from, state) do
    res = :erlang.apply(mod, fun, args)
    {:reply, res, state}
  end

  def handle_cast({:add, {mod, fun, args}}, state) do
    _res = :erlang.apply(mod, fun, args)
    {:noreply, state}
  end

  def handle_cast({:suspend, _}, state) do
    Process.sleep(Application.get_env(:slack, :api_throttle))
    {:noreply, state}
  end

end
