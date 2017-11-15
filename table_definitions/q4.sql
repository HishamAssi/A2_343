-- Left-right

-- TODO: Check for a zero case

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS country_and_party CASCADE;
DROP VIEW IF EXISTS country_and_position CASCADE;
DROP VIEW IF EXISTS r0_2 CASCADE;
DROP VIEW IF EXISTS r0_2_without0 CASCADE;
DROP VIEW IF EXISTS r0_2_with0 CASCADE;
DROP VIEW IF EXISTS r2_4_without0 CASCADE;
DROP VIEW IF EXISTS r2_4_with0 CASCADE;
DROP VIEW IF EXISTS r2_4 CASCADE;
DROP VIEW IF EXISTS r4_6 CASCADE;
DROP VIEW IF EXISTS r4_6_without0 CASCADE;
DROP VIEW IF EXISTS r4_6_with0 CASCADE;
DROP VIEW IF EXISTS r6_8 CASCADE;
DROP VIEW IF EXISTS r6_8_without0 CASCADE;
DROP VIEW IF EXISTS r6_8_with0 CASCADE;
DROP VIEW IF EXISTS r8_10 CASCADE;
DROP VIEW IF EXISTS r8_10_without0 CASCADE;
DROP VIEW IF EXISTS r8_10_with0 CASCADE;

-- INCLUDE COUNTRIES WITH NO PARTIES!!!!!


-- This view contains the country name and all the parties that happen in that country.
CREATE VIEW country_and_party AS
SELECT country.name as countryName, party.id as party_id
FROM country JOIN party ON country.id = party.country_id; 

-- This view contains the country name and the left right position of each of that
-- country's parties.
CREATE VIEW country_and_position AS
SELECT countryName, left_right
FROM country_and_party LEFT JOIN party_position 
ON party_position.party_id=country_and_party.party_id;


-- For the next 15 views we will be creating the histogram of the number of
-- left right parties in each range wanted.

-- The number of parties that have a left_right position in [0-2)
-- Excludes countries with no parties containing a left_right position 
-- in that range. 
CREATE VIEW r0_2_without0 AS
SELECT countryName, count(*) as r0_2
FROM country_and_position
WHERE left_right >= 0 AND left_right < 2
GROUP BY countryName;

-- Set the count of parties to 0 for countries that were excluded in the previous view.
CREATE VIEW r0_2_with0 AS
SELECT c1.countryName, 0 as r0_2 
FROM ((SELECT name as countryName FROM country) EXCEPT (SELECT countryName FROM r0_2_without0)) as c1;

-- This view combines the previous 2 views to include all countries whether they have
-- a left right position in the [0-2).
CREATE VIEW r0_2 AS
(SELECT * FROM r0_2_without0) UNION
(SELECT * FROM r0_2_with0);


-- The next 12 views follow the same logic as the previous 3 views.

CREATE VIEW r2_4_without0 AS
SELECT countryName, count(*) as r2_4
FROM country_and_position
WHERE left_right >= 2 AND left_right < 4
GROUP BY countryName;

CREATE VIEW r2_4_with0 AS
SELECT c1.countryName, 0 as r2_4 
FROM ((SELECT name as countryName FROM country) EXCEPT (SELECT countryName FROM r2_4_without0)) as c1;


CREATE VIEW r2_4 AS
(SELECT * FROM r2_4_without0) UNION
(SELECT * FROM r2_4_with0);



CREATE VIEW r4_6_without0 AS
SELECT countryName, count(*) as r4_6
FROM country_and_position
WHERE left_right >= 4 AND left_right < 6
GROUP BY countryName;

CREATE VIEW r4_6_with0 AS
SELECT c1.countryName, 0 as r4_6 
FROM ((SELECT name as countryName FROM country) EXCEPT (SELECT countryName FROM r4_6_without0)) as c1;


CREATE VIEW r4_6 AS
(SELECT * FROM r4_6_without0) UNION
(SELECT * FROM r4_6_with0);


CREATE VIEW r6_8_without0 AS
SELECT countryName, count(*) as r6_8
FROM country_and_position
WHERE left_right >= 6 AND left_right < 8
GROUP BY countryName;

CREATE VIEW r6_8_with0 AS
SELECT c1.countryName, 0 as r6_8 
FROM ((SELECT name as countryName FROM country) EXCEPT (SELECT countryName FROM r6_8_without0)) as c1;


CREATE VIEW r6_8 AS
(SELECT * FROM r6_8_without0) UNION
(SELECT * FROM r6_8_with0);




CREATE VIEW r8_10_without0 AS
SELECT countryName, count(*) as r8_10
FROM country_and_position
WHERE left_right >= 8 AND left_right <= 10
GROUP BY countryName;


CREATE VIEW r8_10_with0 AS
SELECT c1.countryName , 0 as r8_10 
FROM ((SELECT name as countryName FROM country) EXCEPT (SELECT countryName FROM r8_10_without0)) as c1;


CREATE VIEW r8_10 AS
(SELECT * FROM r8_10_without0) UNION
(SELECT * FROM r8_10_with0);


-- Combines the views of r0_2 and r2_4 with their numeric columns side by side
-- to contain 2 bars of the histogram.
CREATE VIEW r0_4 AS
SELECT r0_2.countryName as countryName, r0_2, r2_4 
FROM r0_2 JOIN r2_4 ON r0_2.countryName=r2_4.countryName;

-- Combine the views r0_4 with r4_6 so we have these three ranges in one table
CREATE VIEW r0_6 AS
SELECT r0_4.countryName as countryName, r0_2, r2_4, r4_6 
FROM r0_4 JOIN r4_6 ON r0_4.countryName=r4_6.countryName;

-- Combine the views r0_6 with r6_8 so we have these three ranges in one table
CREATE VIEW r0_8 AS
SELECT r0_6.countryName as countryName, r0_2, r2_4, r4_6, r6_8
FROM r0_6 JOIN r6_8 ON r0_6.countryName=r6_8.countryName;

-- Combine the views r0_8 with r8_10 so we have these three ranges in one table
CREATE VIEW r0_10 AS
SELECT r0_8.countryName as countryName, r0_2, r2_4, r4_6, r6_8, r8_10
FROM r0_8 JOIN r8_10 ON r0_8.countryName=r8_10.countryName;

-- the answer to the query with all 5 ranges for each country.
INSERT INTO q4 
(SELECT * FROM r0_10);


