-- Committed

SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

CREATE TABLE q5(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(50),
        stateMarket REAL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS past_20_years CASCADE;
DROP VIEW IF EXISTS cab_within_20 CASCADE;

-- Define views for your intermediate steps here.

-- Find the range of the past 20 years
CREATE VIEW past_20_years AS
SELECT max(EXTRACT(YEAR FROM CURRENT_DATE)) -20 as b, max(EXTRACT(YEAR FROM CURRENT_DATE)) as e;

-- Find the cabinets that have started within these 20 years
CREATE VIEW cab_within_20 AS
SELECT  EXTRACT(YEAR FROM start_date) as year, cabinet.id as cabinet_id, previous_cabinet_id, country_id
FROM cabinet, past_20_years
WHERE b <= EXTRACT(YEAR FROM start_date) and EXTRACT(YEAR FROM start_date) <= e;

-- Find the parties that are missing from the cabinet in the previous year

-- Cabinets to previous
CREATE VIEW  party_with_cab AS
SELECT DISTINCT party_id, cabinet_party.cabinet_id, country_id
FROM cabinet_party JOIN cab_within_20 ON cabinet_party.cabinet_id = cab_within_20.cabinet_id;

-- Best scenario is a party is in every cabinet (perfect scenario)
CREATE VIEW party_with_every_cabinet AS
SELECT DISTINCT party.id as party_id, cabinet_id, party.country_id
FROM party JOIN cab_within_20 ON party.country_id = cab_within_20.country_id;

-- Parties that have missed atleast one previous cabinet
CREATE VIEW rule_breakers AS
(SELECT * FROM party_with_every_cabinet) EXCEPT (SELECT * FROM party_with_cab);

-- Parties that have been with every cabinet in the past 20 years
CREATE VIEW every_cabinet AS
(SELECT party_id FROM party_with_cab) EXCEPT (SELECT DISTINCT party_id FROM rule_breakers);

CREATE VIEW party_and_country AS
SELECT country.name as countryName, party.name as partyName, party_id
FROM every_cabinet JOIN party ON party_id=party.id
JOIN country ON party.country_id=country.id;

CREATE VIEW party_and_family AS
SELECT countryName, partyName, family AS partyFamily, party_and_country.party_id
FROM party_and_country LEFT JOIN party_family ON party_and_country.party_id=party_family.party_id;

CREATE VIEW all_info AS
SELECT countryName, partyName, partyFamily, state_market AS stateMarket
FROM party_and_family LEFT JOIN party_position ON party_and_family.party_id=party_position.party_id;

-- the answer to the query 
insert into q5 (SELECT * FROM all_info);