--The tables are ordered by primary key dependency (if that is a term) with teams, players, and seasons needing to be established before performances and games can be recorded

--Table designed to house the teams and is very frequently used as a foreign key for other tables
--Attributes include unique ID, name, year founded, conference, and the number of championships won
CREATE TABLE "teams"(
    "id" INTEGER NOT NULL,
    "location" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "year_founded" INTEGER NOT NULL,
    "conference" TEXT NOT NULL,
    "championships" INTEGER,
    PRIMARY KEY("id")
);

--Table designed to house the players' static information
--Attributes include unique ID, first and last name, current team ID, and position
CREATE TABLE "players"(
    "id" INTEGER NOT NULL,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "team_id",
    "position",
    PRIMARY KEY("id")
    FOREIGN KEY("team_id") REFERENCES "teams"("id")
);

--Table designed to house each season since most statistics will need the seasons separated
--Attributes include unique ID, year, the team ID of the championship team, and any miscellaneous notes like a shortened season from a lockout or Covid
--The autoincrementing nature of the primary key ID will be used in several views and common queries by assuming that the highest integer will be the current or most recent season
CREATE TABLE "seasons"(
    "id" INTEGER NOT NULL,
    "year" NOT NULL,
    "champion_team_id",
    "notes" TEXT,
    PRIMARY KEY("id")
    FOREIGN KEY("champion_team_id") REFERENCES "teams"("id")
);

--Table designed to house the win/loss ratio of each team in each season
--Attributes include the team ID, the season ID, games played, wins, and losses
--Serves primarily as a relationship table
CREATE TABLE "team_performances"(
    "team_id" NOT NULL,
    "season_id NOT NULL"
    "games_played" INTEGER NOT NULL,
    "wins" INTEGER NOT NULL,
    "losses" INTEGER NOT NULL,
    FOREIGN KEY("team_id") REFERENCES "teams"("id")
    FOREIGN KEY("season_id") REFERENCES "seasons"("id")
);


--Table designed to house each players stats in each season
--Attributes include player ID, season ID, team ID, games played, points, field goals made and attempted, free throws made and attempted, rebounds, assists, blocks, and steals
CREATE TABLE "player_performances"(
    "player_id" NOT NULL,
    "season_id" NOT NULL,
    "team_id" NOT NULL,
    "games_played" INTEGER NOT NULL,
    "points" INTEGER NOT NULL,
    "fgm" INTEGER NOT NULL,
    "fga" INTEGER NOT NULL,
    "ftm" INTEGER NOT NULL,
    "fta" INTEGER NOT NULL,
    "rebounds" INTEGER NOT NULL,
    "assists" INTEGER NOT NULL,
    "blocks" INTEGER NOT NULL,
    "steals" INTEGER NOT NULL,
    FOREIGN KEY("player_id") REFERENCES "players"("id")
    FOREIGN KEY("season_id") REFERENCES "seasons"("id")
    FOREIGN KEY("team_id") REFERENCES "teams"("id")
);

--Table designed to house every regular season game
--Attributes include game ID, date, home and away teams' IDs, the winning team's ID, and the season ID
CREATE TABLE "regular_games"(
    "id" INTEGER NOT NULL,
    "date" NUMERIC NOT NULL,
    "home_team_id" NOT NULL,
    "away_team_id" NOT NULL,
    "winning_team_id" NOT NULL,
    "season_id" NOT NULL,
    PRIMARY KEY("id")
    FOREIGN KEY ("home_team_id") REFERENCES "teams"("id")
    FOREIGN KEY ("away_team_id") REFERENCES "teams"("id")
    FOREIGN KEY ("winning_team_id") REFERENCES "teams"("id")
    FOREIGN KEY ("season_id") REFERENCES "seasons"("id")
);

--Table designed to separate playoff and regular-season games for query simplicity
--Attributes include game ID, home and away teams' IDs, the winning team's ID, and the season ID
CREATE TABLE "playoff_games"(
    "id" INTEGER NOT NULL,
    "home_team_id" NOT NULL,
    "away_team_id" NOT NULL,
    "winning_team_id" NOT NULL,
    "season_id" NOT NULL,
    PRIMARY KEY("id")
    FOREIGN KEY ("home_team_id") REFERENCES "teams"("id")
    FOREIGN KEY ("away_team_id") REFERENCES "teams"("id")
    FOREIGN KEY ("winning_team_id") REFERENCES "teams"("id")
    FOREIGN KEY ("season_id") REFERENCES "seasons"("id")
);

--Any common queries that require significant arithmetic operators or are cumbersome to type have been housed more permanently as views to be queried directly

--View for current standings of all 30 teams sorted by win percentage which also captures the playoff picture
CREATE VIEW "current_standings" AS
SELECT "location", "name", "games_played", "wins", "losses", ROUND("wins"*100/"games_played", 2) AS "win_pct"
FROM "teams"
JOIN "team_performances" ON "team_performances"."team_id" = "teams"."id"
WHERE "team_performances"."season_id" = (
    SELECT "id" FROM "seasons"
    ORDER BY "id" DESC
    LIMIT 1
)
ORDER BY "wins"*100/"games_played";

--View for per-game averages of metrics from the player_performances table
CREATE VIEW "current_per_game_avgs" AS
SELECT "first_name", "last_name", ROUND("points"/"games_played", 1) AS "points", ROUND("rebounds"/"games_played", 1) AS "rebounds", ROUND("assists"/"games_played", 1) AS "assists", ROUND("blocks"/"games_played", 1) AS "blocks", ROUND("steals"/"games_played", 1) AS "steals"
FROM "players"
JOIN "player_performances" ON "player_performances"."player_id" = "players"."id"
WHERE "team_performances"."season_id" = (
    SELECT "id" FROM "seasons"
    ORDER BY "id" DESC
    LIMIT 1
);

--View for shooting percentages as calculated from the player_performances table
CREATE VIEW "current_shooting_percentage" AS
SELECT "first_name", "last_name", ROUND("fgm"*100/"fga", 2) AS "field_goal_percentage", ROUND("ftm"*100/"fta", 2) AS "free_throw_percentage"
FROM "players"
JOIN "player_performances" ON "player_performances"."player_id" = "players"."id"
WHERE "player_performances"."season_id" = (
    SELECT "id" FROM "seasons"
    ORDER BY "id" DESC
    LIMIT 1
);

--The following indexes were designed around the most frequent SELECT queries anticipated
--Scans in the query plan were acceptable on smaller tables, like the one only housing the 30 NBA teams

--Index for nested queries regarding team_id
CREATE INDEX "team_name_index"
ON "teams" ("name");

--Index designed to streamline any query dealing with "current season" statistics
CREATE INDEX "season_index"
ON "seasons" ("year");

--Index for nested queries regarding season
CREATE INDEX "season_id_index"
ON "seasons" ("id");

--Index designed to streamline standings reports
CREATE INDEX "team_conference_index"
ON "teams" ("id", "conference");

--Index created to improve searches by player name
CREATE INDEX "player_search_index"
ON "players" ("first_name", "last_name");

--Since player trades would only be changed in one table (players), the only trigger needed would be to update team performances once a game is recorded

--Trigger to update teams' performance after a game record is inserted
CREATE TRIGGER "game_record"
AFTER INSERT ON "regular_games"
FOR EACH ROW
BEGIN
    --Update the winning team's record
    UPDATE "team_performances"
    SET "wins" = "wins" + 1, "games_played" = "games_played" + 1
    WHERE "team_id" = NEW."winning_team_id" AND "season_id" = NEW."season_id"
    --Update the losing team's record
    UPDATE "team_performances"
    SET "losses" = "losses" + 1, "games_played" = "games_played" + 1
    WHERE "team_id" IN (NEW."home_team_id", NEW."away_team_id") AND "season_id" = NEW."season_id"
    AND "team_id" != NEW."winning_team_id"
END;
