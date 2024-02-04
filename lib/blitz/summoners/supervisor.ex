defmodule Blitz.Supervisor do
  use Supervisor

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state)
  end

  @impl true
  def init(state \\ %{}) do
    IO.inspect("starting supervisor's children")

    children = [
      {Blitz.SummonerWorker, state}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
