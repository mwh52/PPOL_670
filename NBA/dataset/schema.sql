
CREATE TABLE Player
        (playerID integer primary key,
        name varchar(50),
        position varchar(10), -- must be guard, center or forward
        height integer, --inches
        weight integer, --lbs
        team varchar(30)) --unique for each player
        ;
CREATE TABLE Team
        (name varchar(30) primary key, --unique
        city varchar(20));  
CREATE TABLE Game
        (gameID integer primary key, -- unique
        homeTeam varchar(30),
        awayTeam varchar(30),
        homeScore integer,
        awayScore integer)--integrity check to make sure homeand away team different?
        ;  
CREATE TABLE GameStats
        (playerID integer key,
         gameID integer key,
         points integer,
         assists integer,
         rebounds integer);

.import creatingPlayers.csv Player
.import creatingTeams.csv Team
.import creatingGames.csv Game
.import creatingGameStats.csv GameStats

--don't have data that can test #6 yet
-- have portland and chicago game logs
