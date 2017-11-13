SET SEARCH_PATH TO parlgov;

DROP VIEW IF EXISTS all_results CASCADE;
DROP VIEW IF EXISTS country_id CASCADE; 

-- Get the country_id from the name
CREATE VIEW Country_id AS
SELECT id AS country_id 
FROM country
WHERE name='Japan';

-- Get a table of all the elections with their next, or NULL if they have no next
CREATE VIEW all_results AS
SELECT e.election_id as election_id, cabinet.id as cabinet_id
FROM (SELECT e1.e_date as e_start, e2.e_date as e_end, e1.id as election_id, e1.country_id as country_id  FROM election e1 LEFT JOIN election e2 ON e1.e_type = e2.e_type AND e1.country_id = e2.country_id AND ((e1.id = e2.previous_parliament_election_id) OR (e1.id = e2.previous_ep_election_id))) AS e
JOIN cabinet ON cabinet.country_id = e.country_id
WHERE ((cabinet.start_date >= e.e_start AND cabinet.start_date <= e.e_end) OR (cabinet.start_date >= e.e_start AND e.e_end is NULL )) AND (e.country_id IN (SELECT * FROM Country_id ));


