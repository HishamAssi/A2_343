SET SEARCH_PATH TO parlgov;

DROP VIEW IF EXISTS all_results CASCADE;


CREATE VIEW all_results AS 

(SELECT cabinet.id as cabinet_id, election as election_id
FROM 
	(SELECT e2.id as election, e1.id as next, e2.e_date as s_date, e1.e_date as end_date, e1.country_id as c_id, e1.e_type as e_type
	FROM election e1 JOIN election e2 ON e1.e_type = e2.e_type AND ((e2.id = e1.previous_parliament_election_id ) OR (e2.id = e1.previous_ep_election_id)) JOIN country ON country.id = e1.country_id AND e1.country_id = e2.country_id
	WHERE country.name = 'Germany') AS election_cabinets 

JOIN cabinet ON election_cabinets.c_id = cabinet.country_id
WHERE election_cabinets.s_date <= cabinet.start_date 
AND election_cabinets.end_date > cabinet.start_date
AND election_cabinets.c_id = cabinet.country_id)

UNION

(SELECT cabinet.id as cabinet_id, election.id as election_id
FROM election JOIN cabinet ON election.country_id = cabinet.country_id JOIN country ON election.country_id = country.id AND country.name='Germany'
WHERE (
election.e_date IN 
	(SELECT max(e_date) as e_date 
	FROM election JOIN country ON election.country_id = country.id
	WHERE country.name = 'Germany'
	GROUP BY (e_type)))
AND (election.e_date <= cabinet.start_date)) 
ORDER BY election_id DESC;

