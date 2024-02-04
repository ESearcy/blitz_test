defmodule RiotApi.Summoners.Summoner do
  defstruct [:accountId, :id, :name, :puuid, :match_ids, :fetched_at, :region]

  def new(map, region) do
    %__MODULE__{
      accountId: map["accountId"],
      region: region,
      id: map["id"],
      name: map["name"],
      puuid: map["puuid"],
      match_ids: [],
      fetched_at: DateTime.utc_now()
    }
  end

  def update_matches(%__MODULE__{} = summoner, matche_ids) do
    %__MODULE__{summoner | match_ids: matche_ids}
  end
end
