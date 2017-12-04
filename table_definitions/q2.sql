-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS winnersByCountry  CASCADE;
DROP VIEW IF EXISTS winnerCount CASCADE;
DROP VIEW IF EXISTS losingParties CASCADE;
DROP VIEW IF EXISTS winningParties1 CASCADE;
DROP VIEW IF EXISTS winningParties CASCADE;
DROP VIEW IF EXISTS winningPartiesWithVotes CASCADE;
DROP VIEW IF EXISTS winnerCount CASCADE;
DROP VIEW IF EXISTS averagePerCountry;
DROP VIEW IF EXISTS eligibleParties;
DROP VIEW IF EXISTS eligiblePartiesWithElections;
DROP VIEW IF EXISTS mostRecentElection;


-- Parties that did not win a specific election. 
CREATE VIEW losingParties  AS 
SELECT DISTINCT e1.election_id as election_id, e1.party_id as party_id 
FROM election_result e1 JOIN election_result e2 ON 
(e1.election_id = e2.election_id) and (e1.votes < e2.votes);

-- Winning parties in an election.
CREATE VIEW winningParties AS
SELECT e1.election_id as election_id, e1.party_id as party_id 
FROM election_result e1 INNER JOIN
(SELECT election_id, max(votes) as votes 
FROM election_result 
GROUP BY election_id) e2
ON e1.election_id = e2.election_id and e1.votes = e2.votes;

-- Winning parties with the number of votes received.
CREATE VIEW winningPartiesWithVotes AS
SELECT winningParties.election_id as election_id, winningParties.party_id as party_id, votes, country_id
FROM (winningParties JOIN election_result ON winningParties.party_id = election_result.party_id and winningParties.election_id = election_result.election_id) JOIN party ON winningParties.party_id = party.id;

-- Number of wins for each party.
CREATE VIEW winnerCount AS
SELECT party_id, count(*) as wonElections, country_id 
FROM winningParties JOIN party ON winningParties.party_id = party.id 
GROUP BY party_id, country_id;

-- Average number of wins for each country based on the number of wins over the number of elections.
CREATE VIEW averagePerCountry AS
SELECT party.country_id, (cast(sum(wonElections) as decimal) / count(*)) as avg
FROM party LEFT JOIN winnerCount ON party.id = party_id
GROUP BY party.country_id;

-- Parties with wins more than 3 times the average of their country's wins.
CREATE VIEW eligibleParties AS
SELECT party_id,wonElections,  averagePerCountry.avg
FROM averagePerCountry JOIN winnerCount ON averagePerCountry.country_id = winnerCount.country_id
WHERE wonElections > 3* averagePerCountry.avg;

-- All eligible parties with all elections that they have won. 
CREATE VIEW eligiblePartiesWithElections AS
SELECT eligibleParties.party_id as party_id, wonElections,election_id, e_date 
FROM (winningParties JOIN eligibleParties ON winningParties.party_id = eligibleParties.party_id) JOIN election ON id = election_id;

-- All eligible parties with the most recent election won.
CREATE VIEW mostRecentElection as
SELECT e1.party_id as party_id, e1.wonElections as wonElections, e1.election_id as MostRecentlyWonElectionId, EXTRACT( YEAR from e1.e_date) as MostRecentlyWonElectionYear
FROM eligiblePartiesWithElections e1 INNER JOIN
(SELECT party_id, max(e_date) as e_date
FROM eligiblePartiesWithElections 
GROUP BY party_id) e2
ON e1.party_id = e2.party_id and e1.e_date = e2.e_date;

-- All eligible parties with needed information.
CREATE VIEW eligible_names AS
SELECT party.country_id, party.name as partyName,mostRecentElection.party_id,  wonElections, mostRecentlyWonElectionId, mostRecentlyWonElectionYear
FROM mostRecentElection JOIN party ON party.id = party_id; 

-- All eligible parties with even more information.
CREATE VIEW eligible_countrynames AS
SELECT country.name as countryName, partyName,party_id,  wonElections, mostRecentlyWonElectionId, mostRecentlyWonElectionYear
FROM eligible_names  JOIN country ON eligible_names.country_id = country.id ;  

-- All relevant information for all eligible parties as per the question specifications.
CREATE VIEW eligible_familynames AS
SELECT countryName, partyName, party_family.family as  partyFamily, wonElections, mostRecentlyWonElectionId, mostRecentlyWonElectionYear
FROM eligible_countrynames LEFT JOIN party_family on eligible_countrynames.party_id = party_family.party_id ;  

-- the answer to the query 
insert into q2 (SELECT * FROM eligible_familynames);


