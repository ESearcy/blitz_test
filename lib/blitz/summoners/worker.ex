defmodule Blitz.SummonerWorker do
  use GenServer
  require Logger

  alias Blitz.Summoners

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state \\ %{}) do
    {:ok, state, {:continue, :trigger_refresh}}
  end

  @impl true
  def handle_continue(:trigger_refresh, state) do
    schedule_sync()
    {:noreply, state}
  end

  @one_min 60 * 1000
  defp schedule_sync() do
    Process.send_after(self(), :fetch, @one_min)
  end

  @impl true
  def handle_info(:fetch, config) do
    # list tracked summoners
    # fetch match history for each summoner
    # if match id's don't match, update summoner & notify via log.

    Summoners.check_tracked_summoners_for_new_matches()

    schedule_sync()
    {:noreply, config}
  end


end
