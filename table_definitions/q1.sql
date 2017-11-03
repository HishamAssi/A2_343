-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);

-- Dropping the views that I'm about to create first just in case
DROP VIEW IF EXISTS past_20 CASCADE;
DROP VIEW IF EXISTS party_votes_ratios CASCADE;
DROP VIEW IF EXISTS from0_5 CASCADE;
DROP VIEW IF EXISTS from5_10 CASCADE;
DROP VIEW IF EXISTS from10_20 CASCADE;
DROP VIEW IF EXISTS from20_30 CASCADE;
DROP VIEW IF EXISTS from30_40 CASCADE;
DROP VIEW IF EXISTS from40 CASCADE;
DROP VIEW IF EXISTS voteRanges CASCADE;

-- Get a table of all the countries and parties that participated in an election that happened in the past 20 years.
CREATE VIEW past_20 AS 
SELECT EXTRACT(YEAR FROM e_date) as year, election.id as e_id, country_id, party_id, votes_valid, votes
FROM election JOIN election_result ON election.id=election_id 
WHERE 1996 <= EXTRACT(YEAR FROM e_date) AND EXTRACT(YEAR FROM e_date) <= 2016;

-- Get ratios.
CREATE VIEW party_votes_ratios AS 
SELECT year, country.name as countryName, (cast(votes as decimal) / cast(votes_valid as decimal))*100 as voteRatio, party.name as partyName
FROM past_20 JOIN country ON country.id=country_id JOIN party ON party.id=party_id;

-- For the next 6 views, I will be creating a different view for the different 
-- ranges to include the ranges in the views.
CREATE VIEW from0_5 AS 
SELECT year, countryName, cast('(0-5]' as VARCHAR(20)) as voteRange, partyName
FROM party_votes_ratios
WHERE 0 < voteRatio AND voteRatio <= 5;

CREATE VIEW from5_10 AS 
SELECT year, countryName, cast('(5-10]' as VARCHAR(20)) as voteRange, partyName
FROM party_votes_ratios
WHERE 5 < voteRatio AND voteRatio <= 10;

CREATE VIEW from10_20 AS 
SELECT year, countryName, cast('(10-20]' as VARCHAR(20)) as voteRange, partyName
FROM party_votes_ratios
WHERE 10 < voteRatio AND voteRatio <= 20;

CREATE VIEW from20_30 AS 
SELECT year, countryName, cast('(20-30]' as VARCHAR(20)) as voteRange, partyName
FROM party_votes_ratios
WHERE 20 < voteRatio AND voteRatio <= 30;

CREATE VIEW from30_40 AS 
SELECT year, countryName, cast('(30-40]' as VARCHAR(20)) as voteRange, partyName
FROM party_votes_ratios
WHERE 30 < voteRatio AND voteRatio <= 40;

CREATE VIEW from40 AS 
SELECT year, countryName, cast('(40+]' as VARCHAR(20))  as voteRange, partyName
FROM party_votes_ratios
WHERE 40 < voteRatio ;

-- Combining all the ranges together.
CREATE VIEW allRanges AS
SELECT * FROM (
(SELECT * FROM from0_5) UNION
(SELECT * FROM from5_10) UNION 
(SELECT * FROM from10_20) UNION
(SELECT * FROM from20_30) UNION
(SELECT * FROM from30_40) UNION
(SELECT * FROM from40)) AS from0_100;

-- the answer to the query 
insert into q1 (SELECT * FROM allRanges);



