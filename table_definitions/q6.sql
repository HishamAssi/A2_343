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

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS current_cabinet CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW current_cabinet AS
SELECT id as cabinetId, cabinet.start_date, null as end_date 
FROM (SELECT country_id, max(start_date) as start_date FROM cabinet GROUP BY country_id) AS max_years
JOIN cabinet ON max_years.country_id = cabinet.country_id AND max_years.start_date=cabinet.start_date;

CREATE VIEW previous_cabinets AS
SELECT c1.id as cabinetId, c1.start_date AS start_date, c2.start_date AS end_date 
FROM cabinet c1 JOIN cabinet c2 ON c2.previous_cabinet_id=c1.id;

-- the answer to the query 
insert into q6 
