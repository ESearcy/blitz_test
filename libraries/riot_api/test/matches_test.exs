defmodule RiotApi.MatchesTest do
  use ExUnit.Case

  alias RiotApi.Matches
  alias RiotApi.Matches.Match

  setup do
    cache = Cachex.start_link(:matches)
    {:ok, cache: cache}
  end

  test "get_summoner on cache returns the entered summoner" do
    test_match = %Match{match_id: "id"}
    Cachex.put(:matches, "id", test_match)
    match = Matches.get_match("na1", "id")

    assert match.__struct__ == Match
  end
end
