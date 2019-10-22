defmodule AppsignalHammer do
  use Appsignal.Instrumentation.Decorators

  def seed(iterations) do
    1..iterations
    |> Task.async_stream(fn _ -> do_seed() end)
    |> Stream.run()

    ets_info()
  end

  def hammer(iterations, concurrently \\ System.schedulers_online()) do
    {microseconds, _result} =
      :timer.tc(fn ->
        1..iterations
        |> Task.async_stream(fn _ -> instrumented_ok() end,
          max_concurrency: concurrently,
          timeout: 60_000
        )
        |> Stream.run()
      end)

    # microseconds -> seconds
    microseconds / 1_000_000
  end

  def ets_info, do: :ets.info(:"$appsignal_transaction_registry")

  # Exercises the bug that introduces the issue, but swallows the
  # exception so it's easier to repeat in a loop. This variant of
  # the function returns much more quickly than the one that lets
  # the process crash.
  def do_seed do
    instrumented_raise()
  rescue
    RuntimeError -> :error
  end

  @decorate transaction()
  def instrumented_raise do
    raise "rabbits"
  end

  @decorate transaction()
  def instrumented_ok do
    :ok
  end
end
