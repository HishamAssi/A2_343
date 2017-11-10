SET SEARCH_PATH TO parlgov;

CREATE VIEW next_dates AS 
SELECT e2.id as election, e1.id as next, e2.e_date as start_date, e1.e_date as end_date, e1.country_id as country_id; 
FROM (election e1 JOIN election e2 ON e1.e_type = e2.e_type AND ((e2.id = e1.previous_parliament_election_id ) OR (e2.id = e1.previous_ep_election_id)))
WHERE country_id = 5;


CREATE VIEW cabinets AS
SELECT cabinet, election
FROM (next_dates JOIN cabinet) election_cabinets
WHERE cabinet.id IN 
(SELECT cabinet.id
FROM cabinet
WHERE election_cabinets.start_date <= cabinet.start_date 
AND election_cabinets.end_date >= cabinet.end_date
AND election_cabinets.country_id = cabinet.country_id
);
