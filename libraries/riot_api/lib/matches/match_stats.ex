defmodule RiotApi.Matches.SummonerMatchStats do
  defstruct [:match_id, :puuid, :champion, :win]

  def new(map, match_id) do
    %__MODULE__{
      match_id: match_id,
      puuid: map["puuid"],
      win: map["win"],
      champion: map["championName"]
    }
  end
end
