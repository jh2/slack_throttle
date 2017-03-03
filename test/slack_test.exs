defmodule SlackThrottleTest do
  use ExUnit.Case
  alias SlackThrottle.{Queue, API}

  @api_throttle Application.get_env(:slack_throttle, :api_throttle)
  @request_time 100

  test "first queued job starts immediately" do
    s = self()
    Queue.enqueue_cast(random_token(), fn -> send(s, :first_cast) end)
    assert_receive :first_cast, @request_time
  end

  test "queue is rate limited for token" do
    token = random_token()
    s = self()
    Queue.enqueue_cast(token, fn -> send(s, :first_cast) end)
    Queue.enqueue_cast(token, fn -> send(s, :second_cast) end)
    Queue.enqueue_cast(token, fn -> send(s, :third_cast) end)
    refute_receive :third_cast, @api_throttle + @request_time
    assert_receive :third_cast, 2 * @api_throttle + @request_time
  end

  test "queue is not rate limited for different tokens" do
    s = self()
    Queue.enqueue_cast(random_token(), fn -> send(s, :first_cast) end)
    Queue.enqueue_cast(random_token(), fn -> send(s, :second_cast) end)
    assert_receive :first_cast, @request_time
    assert_receive :second_cast, @request_time
  end

  test "queue calls are prioritized over casts" do
    token = random_token()
    s = self()
    Queue.enqueue_cast(token, fn -> send(s, :first_cast) end)
    Queue.enqueue_cast(token, fn -> send(s, :second_cast) end)
    Queue.enqueue_cast(token, fn -> send(s, :third_cast) end)
    Task.start(fn ->
      Queue.enqueue_call(token, fn -> send(s, :first_call) end)
    end)
    assert_receive :first_cast, @api_throttle + @request_time
    assert_receive :first_call, @api_throttle + @request_time
    assert_receive :second_cast, 2 * @api_throttle + @request_time
    assert_receive :third_cast, 3 * @api_throttle + @request_time
  end

  test "api test response with request params" do
    res = API.api_test(%{key: "value"})
    assert res["ok"] == true
    assert res["args"]["key"] == "value"
  end

  test "api auth responds and fails" do
    res = API.auth_test(random_token())
    assert res["ok"] == false
  end

  test "api broadcast returns ok" do
    res = API.auth_test(random_token(), %{}, :cast)
    assert res == :ok
  end

  defp random_token do
    to_string(:rand.uniform)
  end

end
