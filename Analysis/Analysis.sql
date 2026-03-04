-- 1.✅ Basic Queries
-- Select clause
-- view all columns 
select * from matches;
select * from deliveries;
select * from purple_cap;
select * from orange_cap;

-- view specific columns
select match_id,venue,team1,team2,match_winner from matches;
select ball_id,stage,batting_team,bowling_team,striker,bowler from deliveries;
select batsman,team,highest_score from orange_cap;
select bowler,team,best_bowling_figure from purple_cap;

-- WHERE Clause
-- 1.Matches won by a SRH team
select * from matches
where match_winner = 'SRH';

-- 2.Matches played in Hyderabad
select match_id,venue
from matches
where venue like '%Hyderabad';


-- 3.match details on specific Match_ids
select match_id,team1,team2,match_result from matches
where match_id in (44,55);

-- 4.Players with more than 500 runs
select batsman,Runs from orange_cap
where runs > 500;

-- Aggregations
-- 1.Total matches played
select count(*) as Total_Matches from matches;

-- 2. Total runs in season
select sum(runs_of_bat) as total_runs from deliveries;

-- 3.Average win by runs & Average balls left in season
select round(avg(wb_runs),2) as win_by_runs from matches; --  on average,teams won by 15 runs
select round(avg(balls_left),2) as balls_left from matches;  -- On average, chasing teams won with 11 balls remaining.



-- Basic - Intermediate Topics

-- GROUP BY & HAVING
-- 1.checking duplicates
select match_id , count(*) from matches 
group by  match_id
having count(*) > 1;

-- 2.Matches won by each team
select match_winner,count(*) as wins from matches
group by match_winner 
order by wins desc;

-- 3.total deliveries bowled by each bowler in the season.
select bowler,count(*) as total_balls from deliveries
group by bowler
order by total_balls desc;

-- as overs
SELECT 
    bowler,
    ROUND(COUNT(*)/6) AS overs_bowled
FROM deliveries
GROUP BY bowler;

-- 4.Top 5 Run Scorers
SELECT 
    striker,
    SUM(runs_of_bat) AS total_runs
FROM deliveries
GROUP BY striker
ORDER BY total_runs DESC
LIMIT 5;

-- 5.Top 5 Wicket Takers
SELECT 
    bowler,
    COUNT(*) AS wickets
FROM deliveries
WHERE wicket_type is not null
GROUP BY bowler
having count(*) > 300
ORDER BY wickets DESC
limit 5;

-- 6.Most Runs in Powerplay (Overs 1–6)
SELECT 
    striker,batting_team,
    SUM(runs_of_bat) AS powerplay_runs
FROM deliveries d
WHERE d.over BETWEEN 1 AND 6
GROUP BY batting_team,striker
ORDER BY powerplay_runs DESC;

-- 7.Death Over Specialists (Overs 16–20 Wickets)
SELECT 
    bowler,
    COUNT(*) AS death_wickets
FROM deliveries d
WHERE d.over BETWEEN 16 AND 20
AND wicket_type is not null
GROUP BY bowler
ORDER BY death_wickets DESC;


-- JOINS
-- 1.Total runs scored in each match
SELECT 
    m.match_id,
    m.team1,
    m.team2,
    SUM(d.runs_of_bat) AS total_runs
FROM matches m
JOIN deliveries d 
ON m.match_id = d.match_id
GROUP BY m.match_id, m.team1, m.team2
ORDER BY total_runs DESC;

-- 2.total wickets per match
SELECT 
    m.match_id,
    m.team1,
    m.team2,
    count(d.wicket_type) AS total_wickets
FROM matches m
JOIN deliveries d 
ON m.match_id = d.match_id 
GROUP BY m.match_id, m.team1, m.team2
ORDER BY total_wickets DESC;

-- 3.Orange Cap vs Purple Cap Comparison
SELECT 
    o.Batsman,
    o.runs,
    p.bowler,
    p.wickets
FROM orange_cap o
JOIN purple_cap p 
ON o.position = p.position;

-- Subquery
-- 1.Bowlers Above Avg Wickets
SELECT bowler, wickets
FROM purple_cap
WHERE wickets >
(
    SELECT AVG(wickets)
    FROM purple_cap
);

-- 2.Batters Above Avg runs
select Batsman,runs
from orange_cap
where runs > 
(
	select avg(runs) 
	from orange_cap
);

-- 3.Batter who scored more than season average runs
SELECT striker, SUM(runs_of_bat) AS total_runs
FROM deliveries
GROUP BY striker
HAVING total_runs > (
    SELECT AVG(player_runs)
    FROM (
        SELECT SUM(runs_of_bat) AS player_runs
        FROM deliveries
        GROUP BY striker
    ) as t
);

-- 4.venues where wickets > average wickets
SELECT venue, COUNT(wicket_type) AS total_wickets
FROM deliveries
GROUP BY venue
HAVING total_wickets > (
    SELECT AVG(wkt_count)
    FROM (
        SELECT COUNT(wicket_type) AS wkt_count
        FROM deliveries
        GROUP BY venue
    ) AS t
)ORDER BY total_wickets DESC;


-- CTE(Common Table Expressions)
-- 1.Top Bowlers using CTE
with Top_bowlers as
(
  select bowler,sum(wickets) as total_wickets
  from purple_cap
  group by bowler

)
select * from Top_bowlers
order by total_wickets desc
limit 5;

-- 2.Average runs per match using CTE
WITH match_runs AS (
    SELECT match_id, SUM(runs_of_bat) AS total_runs
    FROM deliveries
    GROUP BY match_id
)
SELECT ROUND(AVG(total_runs),2) AS avg_match_runs
FROM match_runs;

-- Window Functions
-- 1.Rank Batters by Total Runs
SELECT 
    striker,
    SUM(runs_of_bat) AS total_runs,
    RANK() OVER (ORDER BY SUM(runs_of_bat) DESC) AS rank_position
FROM deliveries
GROUP BY striker;

-- 2.Dense Rank (No rank skipping)
SELECT 
    striker,
    SUM(runs_of_bat) AS total_runs,
    DENSE_RANK() OVER (ORDER BY SUM(runs_of_bat) DESC) AS rank_position
FROM deliveries
GROUP BY striker;

-- 3.Compare Each Batter's Runs With Season Average
SELECT 
   striker,
    SUM(runs_of_bat) AS total_runs,
   round( AVG(SUM(runs_of_bat)) OVER (),2) as season_avg,
   round(sum(runs_of_bat) - avg(sum(runs_of_bat)) over (),2 ) as diff
FROM deliveries
GROUP BY striker
order by total_runs desc;

-- VIEWS
-- 1.Top Performers View
CREATE VIEW top_performers AS
SELECT o.batsman,
       o.runs,
       p.bowler,
       p.wickets
FROM orange_cap o
JOIN purple_cap p
ON o.team = p.team;

select * from top_performers;

-- 2.Create Match Summary View
CREATE VIEW match_summary AS
SELECT 
    m.match_id,
    m.team1,
    m.team2,
    SUM(d.runs_of_bat) AS total_runs,
    COUNT(d.player_dismissed) AS total_wickets
FROM matches m
JOIN deliveries d
ON m.match_id = d.match_id
GROUP BY m.match_id, m.team1, m.team2;

SELECT *
FROM match_summary
ORDER BY total_runs DESC;

