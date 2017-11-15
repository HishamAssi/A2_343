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
DROP VIEW IF EXISTS rule_breakers CASCADE;


-- All the elections that occured in the past 15 years. The table view contain country_id, 
-- year of the election, the number electorate and the number of votes cast.
CREATE VIEW past_15 AS 
SELECT country_id, EXTRACT(YEAR FROM e_date) as Year, electorate, votes_cast
FROM election
WHERE 2001 <= EXTRACT(YEAR FROM e_date) AND EXTRACT(YEAR FROM e_date) <= 2016;

-- The participation ratio of a country's population in a single election.
-- The view will have the country_id, the year the election occured and the participation ratio.
CREATE VIEW participation_ratio AS
SELECT country_id, Year, (cast(votes_cast as decimal) / cast(electorate as decimal)) as participationRatio
FROM past_15;

-- The participation ratio of a country's population in a single year.
-- The view will have the country_id, the year the election(s) occured and the average participation ratio
-- if more than one election occured at a year.
CREATE VIEW avg_participation_ratio AS
SELECT country_id, Year, sum(participationRatio) / cast(count(*) as decimal) as participationRatio
FROM participation_ratio
GROUP BY country_id, Year;

-- This view will contain the country ids of all the countries that had a decreasing participation ratio.
CREATE VIEW rule_breakers AS
SELECT DISTINCT apr1.country_id
FROM avg_participation_ratio as apr1 JOIN avg_participation_ratio as apr2 
ON apr1.country_id=apr2.country_id AND apr1.year>apr2.year AND apr1.participationRatio<apr2.participationRatio;

-- Get all the countries that did not occur in rule_breakers.
CREATE VIEW rule_abiders AS
(SELECT DISTINCT country_id FROM avg_participation_ratio) EXCEPT (SELECT country_id FROM rule_breakers);

-- Joining all the rule abiders with their respective participation ratio.
-- This view will contain the country_id, the year and the participation ratio.
CREATE VIEW good_participation_ratio AS
SELECT avg_participation_ratio.country_id, Year, participationRatio
FROM avg_participation_ratio JOIN rule_abiders ON 
avg_participation_ratio.country_id = rule_abiders.country_id;


-- This table contains the countries that have only one election in the past 15 years.
-- Such countries will be included in the final answer as they trivially satisfy the requirements. 
CREATE VIEW exactly_one_election AS
SELECT avg_participation_ratio.country_id, avg_participation_ratio.Year, avg_participation_ratio.participationRatio
FROM (SELECT country_id FROM avg_participation_ratio
GROUP BY country_id
HAVING count(*) = 1) exactly1 LEFT JOIN avg_participation_ratio ON exactly1.country_id = avg_participation_ratio.country_id;


-- Joining the countries that had one election with the countries that have more than one.
-- This table contains the countr name, the year of the election and participation ratio in that year.
-- Only countries with non-decreasing participation ratio will be included in this table.
CREATE VIEW good_participation_ratio_w_countryname AS
(SELECT country.name, year, participationRatio
FROM good_participation_ratio JOIN country 
ON good_participation_ratio.country_id = country.id) 
UNION (SELECT country.name, year, participationRatio 
FROM exactly_one_election JOIN country ON exactly_one_election.country_id = country.id);





-- the answer to the query containing everything from the good_participation_ratio_w_countryname. 
insert into q3 (SELECT * FROM good_participation_ratio_w_countryname);

