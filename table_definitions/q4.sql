-- Left-right

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

-- Define views for your intermediate steps here.
CREATE VIEW country_and_party AS
SELECT country.id as country_id, party.id as party_id
FROM country JOIN party ON country.id = party.country_id; 

CREATE VIEW country_and_position AS
SELECT country_id, left_right
FROM country_and_party LEFT JOIN party_position 
ON party_position.party_id=country_and_party.party_id;

CREATE VIEW r0_2_without0 AS
SELECT country_id, count(*) as r0_2
FROM country_and_position
WHERE left_right >= 0 AND left_right < 2
GROUP BY country_id;

CREATE VIEW r0_2_with0 AS
SELECT c1.country_id, 0 as r0_2 
FROM ((SELECT id as country_id FROM country) EXCEPT (SELECT country_id FROM r0_2_without0)) as c1;


CREATE VIEW r0_2 AS
(SELECT * FROM r0_2_without0) UNION
(SELECT * FROM r0_2_with0);


-- the answer to the query 
INSERT INTO q4 


