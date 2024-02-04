# Blitz

While this project is a phoenix project, we are not using the UI.

-- in this project we have a underlying library created for fetching data from the riot service and caching those results to help reduce the number of api calls made to their servers. (to save us some previous rate limits)

-- that can be found in ./libraries/riot_api
-- We are also using caches here to avoid needing to store data in a database. it didn't seem necessary.
-- to launch and test please use:

RIOT_API_KEY=yourkey iex -S mix phx.server

-- using this command you are able to fetch a list of champions this summoner used in their past 5 games.

Blitz.Summoners.fetch_summoner("na1", "soknorb")

-- by running that command, this player is added to our summoners Cache within the riot_api library.
-- when added, we track the timestamp of when the player was looked up using a fetched_at field.
-- for debugging, you can quick fetch cached summoners this way:

Cachex.get(:summoners, "Soknorb")

-- players in the cache with a fetched_at time of < 1 hour from the current timestamp will have their metches and champion names pulled from Riot API every minute.

-- matches also get cached to avoid unnecessary api calls. matches are also shared between players so it made sense to keep those around.

-- by calling Blitz.Summoners.get_summoner("na1", "soknorb") again, it will cause the fetched_at timestap to reset, thus causing their metches to sync for an additional hour.

# to see Logger.info("Summoner #{summoner.name} completed match #{latest_match_id}") you will have to play a game after running the fetch command. or.. you can change the cached summoner using the following sequence

-- check what summoners are in cache, assuming one exists

{:ok, [summonerName1 | _tail]} = Cachex.keys(:summoners)

{:ok, summoner} = Cachex.get(:summoners, summonerName1)
[latest_match_id] = Blitz.Summoners.fetch_summoner_match_ids(summoner, 1)
summoner = %{summoner | match_ids: Enum.filter(summoner.match_ids, fn match_id -> match_id != latest_match_id end)}
Cachex.put(:summoners, summoner.name, summoner)

-- confirm its updated

Cachex.get(:summoners, summoner.name)

-- this will make their latest match seem like its new

# challange instructions

Create a mix project application that:
● Given a valid summoner_name and region will fetch all summoners this summoner
has played with in the last 5 matches. This data is returned to the caller as a list of
summoner names (see below). Also, the following occurs:
○ Once fetched, all summoners will be monitored for new matches every minute for
the next hour
○ When a summoner plays a new match, the match id is logged to the console,
such as:
■ Summoner <summoner name> completed match <match id>

● The returned data should be formatted as:

[summoner_name_1, summoner_name_2, ...]

●
Please upload this project to Github and send us the link.

Notes:
● Make use of Riot Developer API
○ https://developer.riotgames.com/apis
■ https://developer.riotgames.com/apis#summoner-v4
■ https://developer.riotgames.com/apis#match-v5
○ You will have to generate an api key. Please make this configurable so we can
substitute our own key in order to test.
