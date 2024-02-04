defmodule RiotApi.Summoners do
  @moduledoc """
  This module caches matches to save on rate limiting a bit,
  games stay cached for 1hr
  """

  require Logger

  @default_cache :summoners

  def get_summoner(region, name) do
    case Cachex.get(@default_cache, name) do
      # lookup match
      {:ok, nil} ->
        Logger.info("s cache miss")
        fetch_summoner(region, name)

      {:ok, match} ->
        Logger.info("s cache hit")
        match
    end
  end

  defp fetch_summoner(region, name) do
    case RiotApi.Client.fetch_summoner(region, name) do
      {:error, error} ->
        {:error, error}

      summoner ->
        Cachex.put(@default_cache, summoner.name, summoner, ttl: 60* 60 *1000)
        summoner
    end
  end

  def list_cached_summoners() do
    {:ok, summoner_names} = Cachex.keys(@default_cache)

    Enum.map(summoner_names, fn name ->
      {:ok, summoner} = Cachex.get(@default_cache, name)
      summoner
    end)
  end

  def update_summoner(summoner) do
    Cachex.put(@default_cache, summoner.name, summoner, ttl: 60 * 60 * 1000)
  end
end
