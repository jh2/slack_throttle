defmodule Slack.Queue.Worker do
  use GenServer
  require Logger

  @api_throttle Application.get_env(:slack, :api_throttle)
  @idle 6

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def enqueue_cast(server, fun) do
    GenServer.cast(server, {:add, fun})
  end

  def enqueue_call(server, fun) do
    GenServer.call(server, {:run, fun},
      Application.get_env(:slack, :enqueue_sync_timeout))
  end



  def init(:ok) do
    state = {@idle, []}
    Process.send_after(self, :work, @api_throttle)
    {:ok, state}
  end

  def handle_call({:run, fun}, from, {ttl, q}) do
    q = [{from, fun} | q]
    {:noreply, {ttl, q}}
  end

  def handle_cast({:add, fun}, {ttl, q}) do
    q = q ++ [{nil, fun}]
    {:noreply, {ttl, q}}
  end

  def handle_info(:work, {0, []} = state), do: {:stop, :normal, state}
  def handle_info(:work, {ttl, []}) do
    Logger.info ":work [] ttl #{ttl}"
    Process.send_after(self, :work, @api_throttle)
    {:noreply, {ttl - 1, []}}
  end
  def handle_info(:work, {ttl, [h | t] = q}) do
    Logger.debug ":work [#{Enum.count q}] ttl #{ttl}"

    {from, {mod, fun, args}} = h
    res = :erlang.apply(mod, fun, args)
    if from != nil, do: GenServer.reply(from, res)

    Process.send_after(self, :work, @api_throttle)
    {:noreply, {@idle, t}}
  end

end
