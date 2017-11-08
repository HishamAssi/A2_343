-- Alliances

SET SEARCH_PATH TO parlgov;
drop table if exists q7 cascade;

-- You must not change this table definition.

DROP TABLE IF EXISTS q7 CASCADE;
CREATE TABLE q7(
        countryId INT, 
        alliedParty1 INT, 
        alliedParty2 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS number_elections CASCADE;
DROP VIEW IF EXISTS allied_parties_no_lead CASCADE;

-- Obtain the number of elections that occured in each country.
CREATE VIEW number_elections AS
SELECT country_id, count(id)
FROM election
GROUP BY country_id;


-- Obtain the parties that have been a part of the same alliance (excluding party_leaders).
CREATE VIEW allied_parties_no_lead AS
SELECT a1.party_id as alliedPartyId1, a2.party_id as alliedPartyId2
FROM election_result a1 JOIN election_result a2
ON a1.alliance_id = a2.alliance_id; 



-- the answer to the query 
insert into q7 
