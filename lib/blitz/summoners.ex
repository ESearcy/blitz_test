defmodule Blitz.Summoners do
 @moduledoc """
  Provides functions for fetching and caching summoner data.
  """

  alias RiotApi.Summoners, as: SummonerCache
  alias RiotApi.Matches, as: MatchCache
  alias RiotApi.Summoners.Summoner

  require Logger

  @doc """
  Returns a list of recently fetched summoners from cache.
  """
  @spec list_tracked_summoners() :: [map()]
  def list_tracked_summoners() do
    SummonerCache.list_cached_summoners()
    |> Enum.filter(fn s -> DateTime.diff(DateTime.utc_now(), s.fetched_at, :hour) < 1 end)
  end

  @doc """
  Fetches a summoner from API cache and returns recent champion data.
  """
  @spec fetch_summoner(String.t(), String.t()) :: [String.t()]
  def fetch_summoner(region, name) do
    summoner = SummonerCache.get_summoner(region, name)
    match_ids = fetch_summoner_match_ids(summoner, 5)
    update_summoner_match_ids(summoner, match_ids)

    matches = Enum.map(match_ids, fn id -> MatchCache.get_match(region, id) end)
    get_champions_played(matches, summoner.puuid)
  end

  def update_summoner_match_ids(summoner, match_ids) do
    Summoner.update_matches(summoner, match_ids)
    |> SummonerCache.update_summoner()
  end

    @doc """
  Fetches match ids for a summoner.
  Handles API errors.
  """
  @spec fetch_summoner_match_ids(map(), integer()) :: [integer()] | {:error, term()}
  def fetch_summoner_match_ids(summoner, count) do
    RiotApi.Client.fetch_match_ids(summoner.region, summoner.puuid, count)
  end

  def get_champions_played(matches, puuid) do
    Enum.map(matches, fn m ->
      [players_info] = Enum.filter(m.player_stats, fn stat -> stat.puuid == puuid end)
      players_info.champion
    end)
  end

  def check_tracked_summoners_for_new_matches() do
    summoners = list_tracked_summoners()

    Enum.map(summoners, fn summoner ->
      case fetch_summoner_match_ids(summoner, 1) do
        [latest_match_id] ->
          if latest_match_id not in summoner.match_ids do
            update_summoner_match_ids(summoner, summoner.match_ids ++ [latest_match_id])
            Logger.info("Summoner #{summoner.name} completed match #{latest_match_id}")
          else
            Logger.info("no new matches")
          end
        [] -> "has no game history"
      end
     end)
  end
end
