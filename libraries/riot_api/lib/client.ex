defmodule RiotApi.Client do
  alias RiotApi.Summoners.Summoner
  alias RiotApi.Matches.Match

  # this key expires every day

  require Logger

  @root_url "api.riotgames.com"

  @doc """
    This will fetch the summoner info for a given summoner name.

    example response:

    %RiotApi.Summoner{
      accountId: "gMsIk3W7mTfMxfoHQc_y3wnzww8rqXAe7x3E68LVO04NDA",
      id: "KwcDdsjUypZINeHpniLFph9XAKojFm9ucCWyRUL1iNu9kUA",
      name: "Soknorb",
      puuid: "_kpx_SQKZlkvGGFWWRP4UmDcCIk9kpjd0v_xRQVUgtS5q_Uz43Y50exxFMoJO90vfPqxrR2hg5N_tQ"
    }
  """
  def fetch_summoner(region, summoner_name)

  def fetch_summoner(region, summoner_name) do
    url =
      "https://#{region}.#{@root_url}/lol/summoner/v4/summoners/by-name/#{summoner_name}?api_key=#{api_key()}"

    case execute(url) do
      :error -> {:error, "failed to fetch summoner"}
      resp -> resp |> Summoner.new(region)
    end
  end

  # example https://americas.api.riotgames.com/lol/match/v5/matches/NA1_4911340690?api_key=RGAPI-4c3dc86a-cbf7-44ec-946e-d6a43ac701b2
  def fetch_match_ids(region, summoner_puuid, count \\ 5)

  def fetch_match_ids(region, summoner_puuid, count) do
    region_prefix = translate_region(region)
    url =
      "https://#{region_prefix}.#{@root_url}/lol/match/v5/matches/by-puuid/#{summoner_puuid}/ids?start=0&count=#{count}&api_key=#{api_key()}"

      case execute(url) do
        :error ->
          {:error, "failed to fetch summoner match id's for summoner_puuid: #{summoner_puuid}"}

        resp ->
          resp
      end
  end

  def fetch_match_info(region, match_id)

  def fetch_match_info(region, match_id) do
    region_prefix = translate_region(region)

    url =
      "https://#{region_prefix}.#{@root_url}/lol/match/v5/matches/#{match_id}?api_key=#{api_key()}"

      case execute(url) do
        :error -> {:error, "failed to fetch match details for match_id: #{match_id}"}
        resp -> resp |> Match.new()
      end
  end

  defp execute(url) do
    {:ok, response} =
      Req.new(
        url: url,
        retry: :safe_transient
      )
      |> Req.get()

    case response.status do
      200 -> response.body
      403 -> throw("your api key is invalid, recieving 403 - unauthorized")
      _ -> :error
    end
  end

  defp translate_region(region) do
    region_prefix = String.replace(region, ~r/\d/, "") |> String.downcase()

    cond do
      region_prefix in ["na", "br", "lan", "las"] -> "americas"
      region_prefix in ["kr", "jp"] -> "asia"
      region_prefix in ["eune", "euw", "tr", "ru"] -> "europe"
      region_prefix in ["oce", "ph2", "sg2", "th2", "tw2", "vn2"] -> "sea"
    end
  end

  defp api_key do
    case Application.get_env(:riot_api, :api_key) do
      "no_api_key" -> throw("no api key configured: start app with RIOT_API_KEY=your_api_key")
      key -> key
    end
  end
end
