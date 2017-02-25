defmodule Slack.Queue.Worker do
  @moduledoc false

  use GenServer
  require Logger

  @api_throttle Application.get_env(:slack, :api_throttle)
  @call_timeout Application.get_env(:slack, :enqueue_sync_timeout)
  @idle 1

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def enqueue_cast(server, fun) do
    GenServer.cast(server, {:add, fun})
  end

  def enqueue_call(server, fun) do
    GenServer.call(server, {:run, fun}, @call_timeout)
  end



  def init(:ok) do
    state = {-1, []}
    {:ok, state}
  end

  def handle_call({:run, fun}, from, {ttl, q}) do
    ttl = set_ttl_if_inactive(ttl)
    q = q ++ [{from, fun}] |> Enum.sort(&jobsort/2)
    {:noreply, {ttl, q}}
  end

  def handle_cast({:add, fun}, {ttl, q}) do
    ttl = set_ttl_if_inactive(ttl)
    q = q ++ [{nil, fun}]
    {:noreply, {ttl, q}}
  end

  def handle_info(:work, {0, []} = state), do: {:stop, :normal, state}
  def handle_info(:work, {ttl, []}) do
    Logger.debug ":work [] ttl #{ttl}"
    Process.send_after(self, :work, @api_throttle)
    {:noreply, {ttl - 1, []}}
  end
  def handle_info(:work, {ttl, [h | t] = q}) do
    Logger.debug ":work [#{Enum.count q}] ttl #{ttl}"

    {from, {mod, fun, args}} = h
    res = apply(mod, fun, args)
    if from != nil, do: GenServer.reply(from, res)

    Process.send_after(self, :work, @api_throttle)
    {:noreply, {@idle, t}}
  end

  defp set_ttl_if_inactive(-1), do: send(self, :work) && @idle
  defp set_ttl_if_inactive(ttl), do: ttl

  defp jobsort({nil, _fun_a}, {nil, _fun_b}), do: true # cast cast
  defp jobsort({_from_a, _fun_a}, {nil, _fun_b}), do: true # call cast
  defp jobsort({nil, _fun_a}, {_from_b, _fun_b}), do: false # cast call
  defp jobsort({_from_a, _}, {_from_b, _}), do: true # call call

end
