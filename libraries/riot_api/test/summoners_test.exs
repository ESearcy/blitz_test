defmodule RiotApi.SummonersTest do
  use ExUnit.Case

  alias RiotApi.Summoners
  alias RiotApi.Summoners.Summoner

  setup do
    cache = Cachex.start_link(:summoners)
    {:ok, cache: cache}
  end

  test "get_summoner on cache returns the entered summoner" do
    region = "na1"
    name = "TestUser"
    test_summoner = %Summoner{name: name, region: region}
    Summoners.update_summoner(test_summoner)
    summoner = Summoners.get_summoner(region, name)

    assert summoner.__struct__ == Summoner
  end

  test "update_summoner updates summoner fields" do
    region = "na1"
    name = "TestUser"
    test_summoner = %Summoner{name: name, region: region}
    Cachex.put(:summoners, name, test_summoner)
    summoner = Summoners.get_summoner(region, name)
    assert summoner == test_summoner
    updated_summoner = %{summoner | match_ids: ["12345"]}

    Summoners.update_summoner(updated_summoner)
    summoner = Summoners.get_summoner(region, name)
    assert summoner == updated_summoner
  end
end
