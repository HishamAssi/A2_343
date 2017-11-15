-- Sequences

SET SEARCH_PATH TO parlgov;
drop table if exists q6 cascade;

-- You must not change this table definition.

CREATE TABLE q6(
        countryName VARCHAR(50),
        cabinetId INT, 
        startDate DATE,
        endDate DATE,
        pmParty VARCHAR(100)
);


DROP VIEW IF EXISTS current_cabinet CASCADE;
DROP VIEW IF EXISTS previous_cabinets CASCADE;
DROP VIEW IF EXISTS party_and_family_names CASCADE;


-- INCLUDE ALL COUNTRIES REGARDLESS!

-- This view contains the most recent (current) cabinets in each country.
CREATE VIEW current_cabinet AS
SELECT cabinet.country_id, id as cabinetId, cabinet.start_date, null as end_date, cabinet.name 
FROM (SELECT country_id, max(start_date) as start_date FROM cabinet GROUP BY country_id) 
        AS max_years
JOIN cabinet ON max_years.country_id = cabinet.country_id AND max_years.start_date=cabinet.start_date;

-- This view contains all the cabinets that occured before the current one.
-- It contains the country id, cabinet id, start date of a cabinet and the end date of a cabinet
-- as the start date of its next cabinet.
CREATE VIEW previous_cabinets AS
SELECT c1.country_id, c1.id as cabinetId, c1.start_date AS start_date, 
        c2.start_date AS end_date, c1.name
FROM cabinet c1 JOIN cabinet c2 ON c2.previous_cabinet_id=c1.id;

-- Combining the previous cabinets and the current cabinets.
CREATE VIEW all_cabinets AS
(SELECT * FROM previous_cabinets)
UNION
(SELECT * FROM current_cabinet);

-- Gets the country name from the cabinets obtained from the all_cabinets view.
CREATE VIEW get_country_name AS
SELECT country.name as countryName, cabinetid, start_date, end_date, all_cabinets.name
FROM all_cabinets RIGHT JOIN country ON country.id=country_id;

-- Find the party who fills the position of prime minister.
CREATE VIEW party_names AS
SELECT cabinet_id, party.name as party_name
FROM cabinet_party JOIN party ON party_id = party.id
WHERE pm=TRUE;

-- Join the pervious table with get_country_name table to put the information
-- in the right columns.
CREATE VIEW get_party_name AS
SELECT countryName, cabinetid, start_date, end_date, party_name
FROM get_country_name LEFT JOIN party_names ON cabinet_id=cabinetid;  




-- the answer to the query, input everything from get_party_name.
insert into q6 
(SELECT * FROM get_party_name);
