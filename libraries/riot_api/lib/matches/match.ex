defmodule RiotApi.Matches.Match do
  alias RiotApi.Matches.SummonerMatchStats

  defstruct [:match_id, :player_stats]

  def new(map) do
    stats = map["info"]["participants"]
    match_id = map["metadata"]["matchId"]
    player_stats = Enum.map(stats, &SummonerMatchStats.new(&1, match_id))

    %__MODULE__{
      match_id: match_id,
      player_stats: player_stats
    }
  end
end
