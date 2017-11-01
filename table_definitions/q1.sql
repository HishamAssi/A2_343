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


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS past_20 CASCADE;
DROP VIEW IF EXISTS party_votes_ratios CASCADE;

-- Define views for your intermediate steps here.

-- Get a table of all the countries and parties that participated in an election that happened in the past 20 years.
CREATE VIEW past_20 AS 
SELECT EXTRACT(YEAR FROM e_date) as year, election.id as e_id, country_id, party_id, votes_valid, votes
FROM election JOIN election_result ON election.id=election_id 
WHERE 1996 <= EXTRACT(YEAR FROM e_date) AND EXTRACT(YEAR FROM e_date) <= 2016;

-- Get ratios.
CREATE VIEW party_votes_ratios AS 
SELECT year, country.name as countryName, (cast(votes as decimal) / votes_valid)*100 as voteRange, party.name as partyName
FROM past_20 JOIN country ON country.id=country_id JOIN party ON party.id=party_id;


-- the answer to the query 
insert into q1 


