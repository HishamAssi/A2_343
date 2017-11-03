-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS past_15 CASCADE;
DROP VIEW IF EXISTS avg_participation_ratio CASCADE;
DROP VIEW IF EXISTS participation_ratio CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW past_15 AS 
SELECT country_id, EXTRACT(YEAR FROM e_date) as Year, electorate, votes_valid
FROM election
WHERE 2001 <= EXTRACT(YEAR FROM e_date) AND EXTRACT(YEAR FROM e_date) <= 2016;

-- Obtain the participation ratio.
CREATE VIEW participation_ratio AS
SELECT country_id, Year, (cast(votes_valid as decimal) / cast(electorate as decimal)) as participationRatio
FROM past_15;

-- Average the participation ratio for elections occuring in the same year.
CREATE VIEW avg_participation_ratio AS
SELECT country_id, Year, avg(participationRatio) as participationRatio
FROM participation_ratio
GROUP BY country_id, Year;

-- Get the rule breakers (countries that have had a decrease in their participation ratio at least once).
CREATE VIEW rule_breakers AS
SELECT DISTINCT apr1.country_id
FROM avg_participation_ratio as apr1, avg_participation_ratio as apr2
WHERE apr1.country_id=apr2.country_id AND apr1.year>apr2.year AND apr1.participationRatio<apr2.participationRatio;

-- Subtract Rule breakers from the list of countries avg_participation
CREATE VIEW rule_abiders AS
(SELECT DISTINCT country_id FROM avg_participation_ratio) EXCEPT (SELECT country_id FROM rule_breakers);

-- Obtain the average participation ratio from only the rule abiders.
CREATE VIEW good_participation_ratio AS
SELECT avg_participation_ratio.country_id, Year, participationRatio
FROM avg_participation_ratio JOIN rule_abiders ON avg_participation_ratio.country_id = rule_abiders.country_id;






-- the answer to the query 
insert into q3 (SELECT * FROM good_participation_ratio);

