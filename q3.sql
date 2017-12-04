set search_path to quizschema;
drop table if exists q2 cascade;
DROP VIEW IF EXISTS NumericHintCount CASCADE;
DROP VIEW IF EXISTS trueFalseHintCount CASCADE;
DROP VIEW IF EXISTS MCQHintCount CASCADE;
DROP VIEW IF EXISTS allCounts CASCADE;
DROP VIEW IF EXISTS countsWithText CASCADE;

CREATE TABLE q3 (
    s_id INT PRIMARY KEY,
    lastname VARCHAR[255] NOT NULL,
    totalGrade INT NOT NULL
);
 
CREATE VIEW students120 AS
     SELECT s_id 
     FROM class JOIN took ON class.c_id = took.c_id,
     WHERE room = "room 120" AND grade = "grade 8" 
         AND teacher = "Mr Higgins";
 
-- Responses of students in the room 120 grade 8, taking this quiz
CREATE VIEW Responses120 AS
    SELECT question_id, sr.s_id as s_id, quizid,answer, questionType,
    FROM  StudentResponse sr JOIN students120 s  ON sr.s_id = s.s_id
    WHERE sr.quizid = "Pr1-220310";
         
-- CORRECT responses 
CREATE VIEW correctResponses AS
     SELECT s_id, questionid,  quizid,
     FROM Responses120 sr
     WHERE (sr.questionType = "MCQ" AND sr.answer IN 
         (SELECT answer
          FROM MultipleChoice 
          WHERE sr.questionid = questionid AND isAnswer=true))
     OR (sr.questionType = "Numeric" AND sr.answer IN 
         (SELECT startRange
          FROM NumericQuestions 
          WHERE sr.questionid = questionid AND isAnswer=true))
     OR  (sr.questionType = "TF" AND sr.answer IN 
         (SELECT answer
          FROM true_false 
          WHERE sr.questionid = questionid)   
         );

-- Students that got nothing correct 
CREATE VIEW noResponse AS 
    SELECT s_id, 0 as totalGrade
    FROM (SELECT DISTINCT s_id FROM StudentResponse WHERE quizid = "Pr1-220310")
    except
    (SELECT DISTINCT s_id FROM correctResponses WHERE quizid = "Pr1-220310") 

-- Total Weight
CREATE VIEW totalGrades AS
    SELECT s_id, sum(Weight) as totalGrade
    FROM correctResponses cr JOIN includes i ON i.questionid = cr.questionid 
    AND i.quizid = cr.quizid
    GROUP BY s_id;

-- Lastname
CREATE VIEW allInfo AS
    SELECT s_id, lastname, totalGrade
    FROM ((SELECT * FROM totalGrades) UNION (SELECT * FROM noResponse)) rawInfo
    JOIN student ON rawInfo.s_id = student.s_id;


 INSERT into q2 (
     SELECT *
     FROM allInfo
 );  
                                                  34,2-5        Top
