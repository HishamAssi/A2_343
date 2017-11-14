SET SEARCH_PATH TO parlgov;

DROP VIEW IF EXISTS all_results CASCADE;
DROP VIEW IF EXISTS all_resultsOfficial CASCADE;
DROP VIEW IF EXISTS country_id CASCADE; 
 

DROP TABLE IF EXISTS electionD CASCADE;
DROP TABLE IF EXISTS cabinetD CASCADE;
-- Get the country_id from the name

 -- A "cabinet" is the set of government and opposition parties in parliament
-- as of each major change, such as an election or change of prime minister.  
-- This table itself stores the start date of a cabinet and other general 
-- information it.  Table cabinet_party, which references this table,
-- stores the political parties that were part of this cabinet.
CREATE TABLE cabinetD(
  id INT PRIMARY KEY,
  -- The country in which this cabinet occurred.
  country_id INT REFERENCES country(id),
  -- The date on which this cabinet came into being.
  start_date INT  NOT NULL
  -- A label for this cabinet, consisting of the family name of the
);

-- Election results for a parliamentary election or European parliament
-- election.  European parliament elections are recorded here by country.
CREATE TABLE electionD(
  id INT primary key,
  -- The country whose election information this is.
  country_id INT REFERENCES country(id),
  -- The date of this election.
  e_date INT  NOT NULL,
  previous_parliament_election_id INT REFERENCES electionD(id),
  -- ID of the previous EP election in this country, or
  -- NULL if there is no previous EP election in the database.
  -- Note: Even parliamentary elections have this attribute.
  -- Constraint: The country_id for this election and the previous
  -- EP election must be the same.
  previous_ep_election_id INT REFERENCES electionD(id),
  -- The type of election this was.
  e_type VARCHAR(200) NOT NULL 
);


INSERT into electionD VALUES (3, 29, 2018,2, 1,'e'), (2, 29, 1990,1, NULL, 'p'), (1, 29, 1920, NULL, NULL, 'p');
INSERT INTO cabinetD VALUES (3,5,2017), (2, 29, 2017), (1, 29, 1920);


CREATE VIEW Country_id AS
SELECT id AS country_id 
FROM country
WHERE name='Japan';

-- Get a table of all the elections with their next, or NULL if they have no next
CREATE VIEW all_results AS
SELECT e.election_id as election_id, cabinetD.id as cabinet_id
FROM (SELECT e1.e_date as e_start, e2.e_date as e_end, e1.id as election_id, e1.country_id as country_id  FROM electionD e1 LEFT JOIN electionD e2 ON e1.e_type = e2.e_type AND e1.country_id = e2.country_id AND ((e1.id = e2.previous_parliament_election_id) OR (e1.id = e2.previous_ep_election_id))) AS e
LEFT JOIN cabinetD ON cabinetD.country_id = e.country_id AND ((cabinetD.start_date >= e.e_start AND cabinetD.start_date <=e.e_end) OR (cabinetD.start_date >= e.e_start AND e.e_end is NULL )) 
where (e.country_id = 29);

CREATE VIEW all_resultsOfficial AS
SELECT e.election_id as election_id, cabinet.id as cabinet_id
FROM (SELECT e1.e_date as e_start, e2.e_date as e_end, e1.id as election_id, e1.country_id as country_id  FROM election e1 LEFT JOIN election e2 ON e1.e_type = e2.e_type AND e1.country_id = e2.country_id AND ((e1.id = e2.previous_parliament_election_id) OR (e1.id = e2.previous_ep_election_id))) AS e
LEFT JOIN cabinet ON cabinet.country_id = e.country_id AND ((cabinet.start_date >= e.e_start AND cabinet.start_date <=e.e_end) OR (cabinet.start_date >= e.e_start AND e.e_end is NULL )) 
where (e.country_id = 5);
