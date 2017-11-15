-- Alliances

SET SEARCH_PATH TO parlgov;
drop table if exists q7 cascade;

-- You must not change this table definition.

DROP TABLE IF EXISTS q7 CASCADE;
CREATE TABLE q7(
        countryId INT, 
        alliedPartyId1 INT, 
        alliedPartyId2 INT
);


DROP VIEW IF EXISTS number_elections CASCADE;
DROP VIEW IF EXISTS allied_parties CASCADE;

-- This view contains 30% the number of elections that have occured in a country.
CREATE VIEW number_elections AS
SELECT country.id AS countryId, count(election.id) * 0.3 as thirtyperc
FROM election JOIN country ON country_id=country.id
GROUP BY country.id;


-- This view contains all pairs of parties that were part of the same alliance in
-- an election, avoiding symmetric pairs.
CREATE VIEW allied_parties AS
SELECT e1.party_id as alliedPartyId1, e2.party_id as alliedPartyId2
FROM election_result e1 JOIN election_result e2 ON
e1.election_id=e2.election_id AND e1.party_id < e2.party_id AND 
((e1.alliance_id=e2.alliance_id) OR (e1.alliance_id IS NULL 
AND e2.alliance_id=e1.id) OR (e2.alliance_id IS NULL AND e1.alliance_id=e2.id));


-- Get the country id for all pairs.
CREATE VIEW allied_parties_w_countries AS
SELECT country_id AS countryId, alliedPartyId1, alliedPartyId2
FROM allied_parties JOIN party ON party.id = alliedPartyId1;

-- This view filters out all the pairs that had a count less than 30 percent of the
-- country's number of elections.
CREATE VIEW alliance_counts AS 
SELECT allied_parties_w_countries.countryId, alliedPartyId1, alliedPartyId2
FROM allied_parties_w_countries JOIN number_elections ON 
allied_parties_w_countries.countryId=number_elections.countryId
GROUP BY allied_parties_w_countries.countryId, alliedPartyId1, alliedPartyId2, thirtyperc
HAVING count(*) >= thirtyperc;



-- the answer to the query 
insert into q7 (SELECT * FROM alliance_counts);
