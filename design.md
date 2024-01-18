# Design Document

NBA Records Database

By James Schuyler Bacon

Video overview: <URL HERE>

## Scope

This database includes all entities needed to track team and individual player performances derived from NBA games
The entities included are:
*Teams, including basic information
*Players, including basic information
*Seasons, including the year and and any miscellaneous notes
*Team Performances comprised of wins, losses, and games played in any given season
*Player Performances which includes several common metrics measured by the NBA for each player in any given season, including games played, points, rebounds, assists, and more
*Regular Games, including the date, season, teams playing, and the victor
*Playoff Games are separated from regular season games for record simplicity and do not record date

Out of the scope of this database are records of player trades, salaries, niche player statistics, or records of team location and name changes

## Functional Requirements

This database should facilitate the following:
*CRUD functionality with player profiles, individual performances, and games
*Cross-table queries to find answers to analysis questions
*Updating data into future season ID's

Beyond the scope of this database's functionality is web scraping using common statistic websites and tracking player trade and salary information

## Representation

### Entities

The database includes the following entities:

#### Teams

The "teams" table includes:
*"id" for the UNIQUE PRIMARY KEY INTEGER that identifies each team
*"location" as a TEXT field to capture the city or state that begins each team name
*"name" as another TEXT field to record each team's name
*"year_founded" is an INTEGER field that records the year during which each team was founded in its earliest version
*"conference", which specifies if the team is in the Western or Eastern Conference. TEXT is the appropriate data type
*"championships" for the INTEGER that defines how many championships each team has won in its franchise history

All of the columns on the "teams" table except "champsionships also have the NOT NULL constraint.

#### Players

The "players" table includes:
*"id" for the UNIQUE PRIMARY KEY INTEGER that identifies each player
*"first_name" specifies each player's first name as a TEXT field
*"last_name" similarly records each player's last name as a TEXT field
*"team_id" denotes the ID of the player's team. This column has the FOREIGN KEY constraint, referring to the "id" column of the "teams" table
*"position" records an abbreviation of the player's position(s) as a TEXT field (e.g. "Small Forward" as "SF")

The first_name and last_name fields both have the NOT NULL constraint applied. As a player might not be currently active on a team or have a distinct role, those columns do not need this constraint.

#### Seasons

The "seasons" table includes:
*"id" for the UNIQUE PRIMARY KEY INTEGER that identifies each season
*"year" records the years during which the season occurred as a TEXT field (e.g. 2023-2024)
*"champion_team_id" captures the team ID of whichever team won that season's championship. This column has the FOREIGN KEY constraint, referring to the "id" column of the "teams" table
*"notes" is a TEXT field to capture any miscellaneous notes. This column is designed to explain seasons with fewer than 82 games because of a lockout or similar extenuating circumstance.

The "year" column is the only column with the NOT NULL constraint applied as it is required for the season record to be reasonably queried.

#### Team Performances

The "team_performances" table includes:
*"team_id" refers to the team in question by team ID. Like previous instances, this column has the FOREIGN KEY constraint, referring to the "id" column of the "teams" table
*"season_id" refers to the season during which the team record occurred. This column has the FOREIGN KEY constraint, referring to the "id" column of the "seasons" table
*"games_played" is an INTEGER field to record how many games the team has played during that season (so far).
*"wins" notes the number of wins the team earned that season as an INTEGER.
*"losses" does the same for losses as an INTEGER field.

As each column is required in this relationship table, all fields also have the NOT NULL constraint

#### Player Performances

The "player_performances" tbale includes:
*"player_id" records the ID of the player in question. This column has the FOREIGN KEY constraint, referring to the "id" column of the "players" table
*"season_id" refers to the season during which the player performance occurred. This column has the FOREIGN KEY constraint, referring to the "id" column of the "seasons" table
*"team_id" captures the ID of the team that employed the player during the performance. This column has the FOREIGN KEY constraint, referring to the "id" column of the "teams" table
*"games_played" is an INTEGER field that records the number of games played for this performance.
*"points" is an INTEGER field that captures how many points the player scored.
*"fgm" is an INTEGER field for the number of shots ('field goals') made by the player.
*"fga" is a related INTEGER field of the number of shots attempted.
*"ftm" records the number of free throws made by the player as an INTEGER.
*"fta" is the number of free throws the player attempted as an INTEGER.
*"rebounds" is an INTEGER that tallies the number of rebounds performed by the player.
*"assists" is an INTEGER that tallies the number of assists performed by the player.
*"blocks" is an INTEGER that tallies the number of blocks performed by the player.
*"steals" is an INTEGER that tallies the number of steals performed by the player.

Player records are designed to begin with a zero in most of the fields, and each column is required. Thus, every column in the "player_performances" table has the NOT NULL constraint.

#### Regular Games

The "regular_games" table includes the following:
*"id" for the UNIQUE PRIMARY KEY INTEGER that identifies each regular season game
*"date" is a NUMERIC field to capture the date on which the game was played.
*"home_team_id" is the team ID of the home team. This column has the FOREIGN KEY constraint, referring to the "id" column of the "teams" table.
*"away_team_id" is the team ID of the away team. This column also has the FOREIGN KEY constraint on the "teams" table "id" column.
*"winning_team_id" is the team ID of whichever team won. Predictably, this column has a FOREIGN KEY constraint on the "teams"."id" column.
*"season_id" is the ID of the season during which the game was played. The FOREIGN KEY constraint relates this column to the "id" column of the "seasons" table.

Every column in the "regular_games" table is required, so the NOT NULL constraint is applied to them all.

#### Playoff Games

The "playoff_games" table includes:
*"id" for the UNIQUE PRIMARY KEY INTEGER that identifies each regular season game
*"home_team_id" is the team ID of the team playing the home playoff seed. This column has the FOREIGN KEY constraint, referring to the "id" column of the "teams" table.
*"away_team_id" is the team ID of the team playing from the away playoff seed. This column also has the FOREIGN KEY constraint on the "teams" table "id" column.
*"winning_team_id" is the team ID of whichever team won. This column has a FOREIGN KEY constraint on the "teams"."id" column.
*"season_id" is the ID of the season of this playoff series. The FOREIGN KEY constraint relates this column to the "id" column of the "seasons" table.

Every column in the "playoff_games" table is required, so the NOT NULL constraint is applied to them all.

### Relationships

[![ER Diagram](https://mermaid.ink/img/pako:eNqNkdFqwyAUhl9FznWbB_BONtObpim6XQyEItF20qrB6UWJeffFdBmMkbE7PX5-_Jx_gM4rDRh0eDbyEqQV7oWShqPst9s8oOOevFHGEUba9jd_F26Z5FxVfgFOR8rqljXk8EQL3AevUqfRty3PtnJZQRfxz-expMiIU8LbQ6FVCsZdHtp_oozuXveEnXakmbGqWkli3NkH-_vDirfkbev6bww2YHWw0qhpyYNwCAmI79pqAXg6KhmuAoQbJ06m6PnddYBjSHoDqVcy6q9aAJ_l7WOaamWiD82jtbm88RNfL5Dn?type=png)

The relationships outlined in the above diagram:

*A team must employ at least one but probably many players. Conversely, a player might have 0 teams but will play for, at most, one team at a time.
*A player might produce 0 performances without being on a team, but they might play for more than one season, leading to multiple performance records for one player. At the same time, each performance requires one and only one player.
*A team has at least one team performance during its first season, and it can have many during subsequent seasons. Each team performance has exactly one team.
*A player performance requires one and only one season, but a season can have 0 player performances before a game is played or many after the first game.
*A team performance requires one and only one season as well. Similarly, before the first game, a season can have 0 team performances, and afterward, many.
*Regular games affect exactly two team performances. A team performance can have 0 games or many depending on how many games the team has played.
*Regular games require one and only one season. A season can have 0 games before games are played or many afterward.
*Playoff games require a season and only one while a seasons has 0 playoff games during the season or many during the playoffs.

## Optimizations

The queries.sql file identifies anticipated common queries. Users will search for records by team ID using the team's name, so an index was created on the "name" column of the "teams" table.
Because of nested queries that involve season ID or year, indexes were created on both of those columns of the "seasons" table. To streamline the commonly queried conference standings, an index was created for the "id" and "conference" columns of the "teams" table.
Finally, to facilitate player searches and index was created for the "first_name" and "last_name" columns of that table.

Users will likely search for teams or players by advanced metrics derived from existing records. Thus, views were created with the most common of those advanced metrics, including league standings, player shooting percentages, and per-game averages.

To streamline the "team_performances" table, a trigger was created to update the respective teams involved in any "games" INSERT query.

## Limitations

This version of the database schema does not account for a team's historic playoff record. To facilitate this, a new relationship would need to be created between those tables. This schema also does not automate any element of the "player_performances" table, meaning users would need to conduct multiple manual queries for any given game.

This database can show top performers in the league, but it cannot effectively illustrate the top performers in relation to their pay or experience in the league.
