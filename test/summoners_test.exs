defmodule Blitz.SummonersTest do
  use ExUnit.Case

  alias Blitz.Summoners


  describe "get_champions_played/2" do
    test "returns list of champions played" do
      puuid = "puuid"
      matches = [
        %{player_stats: [%{puuid: puuid, champion: "Zed"}]},
        %{player_stats: [%{puuid: puuid, champion: "Yasuo"}]}
      ]

      assert Summoners.get_champions_played(matches, puuid) == ["Zed", "Yasuo"]
    end
  end

  # describe "check_tracked_summoners_for_new_matches/0" do
  #   test "returns list of summoners with new matches" do
  #     TODO
  #   end
  # end
end
