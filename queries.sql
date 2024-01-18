--These are examples of common queries that a user is expected to conduct

-- View current season standings for the Western Conference
SELECT * FROM "current_standings"
WHERE "conference" = 'west';

--View individual performances of players on the Oklahoma City Thunder during the 23-24 season
SELECT * FROM "player_performances"
JOIN "teams" ON "teams"."id" = "player_performances"."team_id"
WHERE "teams"."name" = 'Thunder'
AND "season_id" = (
    SELECT "id" FROM "seasons"
    WHERE "year" = '23-24'
);

--View the top 20 players by current free throw shooting accuracy
SELECT "first_name", "last_name", "free_throw_percentage" FROM "current_shooting_percentage"
ORDER BY "free_throw_percentage" DESC
LIMIT 20;

--View which NBA championships were won by the Los Angeles Lakers
SELECT "year" FROM "seasons"
WHERE "champion_team_id" = (
    SELECT "id" FROM "teams"
    WHERE "name" = 'Lakers'
);

--Identify players with above-average shooting percentage in the Eastern Conference and sort by that shooting percentage
SELECT "first_name", "last_name", "field_goal_percentage"
FROM "current_shooting_percentage"
WHERE "team_id" IN (
    SELECT "id" FROM "teams"
    WHERE "conference" = 'east'
) AND "field_goal_percentage" > (
    SELECT AVG("field_goal_percentage")
    FROM "current_shooting_percentage"
    WHERE "team_id" IN (
        SELECT "id" FROM "teams"
        WHERE "conference" = 'east'
    )
) ORDER BY "field_goal_percentage" DESC;

--Insert an impressive performance from Chet Holmgren
UPDATE "player_performances"
SET
    "games_played" = "games_played" + 1,
    "points" = "points" + 24,
    "fgm" = "fgm" + 9,
    "fga" = "fga" + 14,
    "ftm" = "ftm" + 4,
    "fta" = "fta" + 4,
    "rebounds" = "rebounds" + 9,
    "assists" = "assists" + 4,
    "blocks" = "blocks" + 6
WHERE "player_id" = (
    SELECT "player_id"
    WHERE "first_name" = 'Chet' AND "last_name" = 'Holmgren'
) AND "season_id" = (
    SELECT "id" FROM "seasons"
    WHERE "year" = '23-24'
);
