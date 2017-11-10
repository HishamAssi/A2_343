SET SEARCH_PATH TO parlgov;

DROP VIEW IF EXISTS next_dates CASCADE;
DROP VIEW IF EXISTS eligible_cab CASCADE;


CREATE VIEW next_dates AS 
SELECT e2.id as election, e1.id as next, e2.e_date as s_date, e1.e_date as end_date, e1.country_id as c_id, e1.e_type as e_type
FROM election e1 JOIN election e2 ON e1.e_type = e2.e_type AND ((e2.id = e1.previous_parliament_election_id ) OR (e2.id = e1.previous_ep_election_id))
WHERE e1.country_id = 44;


CREATE VIEW eligible_cab AS
SELECT election_cabinets.id as cabinet_id, election as election_id,next, e_type, start_date as c_start, s_date, end_date
FROM (SELECT * FROM next_dates JOIN cabinet ON next_dates.c_id = cabinet.country_id) election_cabinets
WHERE election_cabinets.id IN 
(SELECT cabinet.id
FROM cabinet
WHERE election_cabinets.s_date <= cabinet.start_date 
AND election_cabinets.end_date > cabinet.start_date
AND election_cabinets.country_id = cabinet.country_id
);

-- Find the most recent election with no next
CREATE VIEW most_recent_election_cab AS
SELECT cabinet.id as cabinet_id, election.id as election_id
FROM election JOIN cabinet ON election.country_id = cabinet.country_id AND election.country_id = 44
WHERE (election.id NOT IN (SELECT election FROM next_dates)) AND (election.e_date <= cabinet.start_date);

CREATE VIEW all_results AS 
(SELECT cabinet_id, election_id
FROM eligible_cab)

UNION

(SELECT cabinet_id, election_id
FROM most_recent_election_cab);
