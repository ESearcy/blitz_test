defmodule RiotApi.Matches do
  @moduledoc """
  This module caches matches to save on rate limiting a bit,
  games stay cached for 8hr
  """

  require Logger

  @default_cache :matches

  def get_match(region, match_id, cache \\ @default_cache)

  def get_match(region, match_id, cache) do
    case Cachex.get(cache, match_id) do
      # lookup match
      {:ok, nil} ->
        Logger.info("m cache miss")
        fetch_match(region, match_id, cache)

      {:ok, match} ->
        Logger.info("m cache hit")
        match
    end
  end

  defp fetch_match(region, match_id, cache) do
    case RiotApi.Client.fetch_match_info(region, match_id) do
      {:error, error} ->
        {:error, error}

      match ->
        Cachex.put(cache, match_id, match, ttl: 60 * 60 * 1000)
        match
    end
  end
end
