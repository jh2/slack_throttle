defmodule SlackThrottle.Queue.Worker do
  @moduledoc false

  use GenServer

  @api_throttle Application.get_env(:slack_throttle, :api_throttle)
  @call_timeout Application.get_env(:slack_throttle, :enqueue_sync_timeout)

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
    state = {:init, []}
    {:ok, state}
  end

  def handle_call({:run, fun}, from, {status, q}) do
    if status == :init, do: send(self(), :work)
    q = q ++ [{from, fun}] |> Enum.sort(&jobsort/2)
    {:noreply, {:active, q}}
  end

  def handle_cast({:add, fun}, {status, q}) do
    if status == :init, do: send(self(), :work)
    q = q ++ [{nil, fun}]
    {:noreply, {:active, q}}
  end

  def handle_info(:work, {:active, []} = state), do: {:stop, :normal, state}
  def handle_info(:work, {:active, [h | t]}) do
    {from, {mod, fun, args}} = h
    res = apply(mod, fun, args)
    if from != nil, do: GenServer.reply(from, res)

    Process.send_after(self(), :work, @api_throttle)
    {:noreply, {:active, t}}
  end

  defp jobsort({nil, _fun_a}, {nil, _fun_b}), do: true # cast cast
  defp jobsort({_from_a, _fun_a}, {nil, _fun_b}), do: true # call cast
  defp jobsort({nil, _fun_a}, {_from_b, _fun_b}), do: false # cast call
  defp jobsort({_from_a, _}, {_from_b, _}), do: true # call call

end
