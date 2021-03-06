-- Question 1
CREATE TABLE EMP(
  ID INT,
  NAME VARCHAR(255),
  RATING INT,
  SUPERVISORID INT,
  DESIGNATION VARCHAR(255)
)

INSERT INTO EMP VALUES(1, 'MAX', 9, 3, 'doc');
INSERT INTO EMP VALUES(2, 'JAMES', 8, 4, 'doc');
INSERT INTO EMP VALUES(3, 'PETER', 6, NULL, 'supervisor');
INSERT INTO EMP VALUES(4, 'SIMON', 9, NULL, 'supervisor');

SELECT E.NAME FROM EMP E INNER JOIN EMP F ON E.SUPERVISORID=F.ID AND E.RATING > F.RATING ;
--or
SELECT E.NAME FROM EMP E WHERE E.RATING > (SELECT RATING FROM EMP F WHERE E.SUPERVISORID=F.ID);


-- Question 2
CREATE TABLE PATIENT(
  PatientId INT,
  EventName VARCHAR(255),
  PhysicianID INT
);

CREATE TABLE EVENTCATEGORY(
  EVENTNAME VARCHAR(255),
  CATEGORY VARCHAR(255)
);

CREATE TABLE PHYSICIAN(
  PHYSICIANID INT,
  SPECIALTY VARCHAR(255)
);

INSERT INTO PATIENT VALUES(1, 'Radiation', 1000);
INSERT INTO PATIENT VALUES(2, 'Chemotherapy', 2000);
INSERT INTO PATIENT VALUES(1, 'Biopsy', 1000);
INSERT INTO PATIENT VALUES(3, 'Immunosuppressants', 2000);
INSERT INTO PATIENT VALUES(4, 'BTKI', 3000);
INSERT INTO PATIENT VALUES(5, 'Radiation', 4000);
INSERT INTO PATIENT VALUES(4, 'Chemotherapy', 2000);
INSERT INTO PATIENT VALUES(1, 'Biopsy', 5000);
INSERT INTO PATIENT VALUES(6, 'Chemotherapy', 6000);

INSERT INTO EVENTCATEGORY VALUES('Chemotherapy', 'Procedure');
INSERT INTO EVENTCATEGORY VALUES('Radiation', 'Procedure');
INSERT INTO EVENTCATEGORY VALUES('Immunosuppressants', 'Prescription');
INSERT INTO EVENTCATEGORY VALUES('BTKI', 'Prescription');
INSERT INTO EVENTCATEGORY VALUES('Biopsy', 'Test');

INSERT INTO PHYSICIAN VALUES(1000, 'Radiologist');
INSERT INTO PHYSICIAN VALUES(2000, 'Oncologist');
INSERT INTO PHYSICIAN VALUES(3000, 'Hematologist');
INSERT INTO PHYSICIAN VALUES(4000, 'Oncologist');
INSERT INTO PHYSICIAN VALUES(5000, 'Pathologist');
INSERT INTO PHYSICIAN VALUES(6000, 'Oncologist');

SELECT SPECIALTY, COUNT(DISTINCT PATIENT.PHYSICIANID) AS SPECIALTY_COUNT FROM PATIENT INNER JOIN EVENTCATEGORY ON PATIENT.EventName=EVENTCATEGORY.EVENTNAME AND CATEGORY = 'PROCEDURE'  INNER JOIN PHYSICIAN ON PATIENT.PhysicianID=PHYSICIAN.PHYSICIANID GROUP BY SPECIALTY;


-- Question 3
CREATE TABLE PATIENTLOGS(
	ACCOUNTID INT,
  	APPOINTMENT DATE,
  	PATIENTID INT
)

INSERT INTO PATIENTLOGS VALUES(1, STR_TO_DATE('2,1,2020', '%d,%m,%Y'), 100);
INSERT INTO PATIENTLOGS VALUES(1, STR_TO_DATE('27,1,2020', '%d,%m,%Y'), 200);
INSERT INTO PATIENTLOGS VALUES(2, STR_TO_DATE('1,1,2020', '%d,%m,%Y'), 300);
INSERT INTO PATIENTLOGS VALUES(2, STR_TO_DATE('21,1,2020', '%d,%m,%Y'), 400);
INSERT INTO PATIENTLOGS VALUES(2, STR_TO_DATE('21,1,2020', '%d,%m,%Y'), 300);
INSERT INTO PATIENTLOGS VALUES(2, STR_TO_DATE('1,1,2020', '%d,%m,%Y'), 500);
INSERT INTO PATIENTLOGS VALUES(3, STR_TO_DATE('20,1,2020', '%d,%m,%Y'), 400);
INSERT INTO PATIENTLOGS VALUES(1, STR_TO_DATE('4,3,2020', '%d,%m,%Y'), 500);

-- w/o the limit per group condition enforced
SELECT MONTHNAME(APPOINTMENT) AS MONTH, ACCOUNTID, COUNT(DISTINCT PATIENTID) AS no_of_unique_patients FROM PATIENTLOGS GROUP BY MONTH, ACCOUNTID ORDER BY no_of_unique_patients DESC, ACCOUNTID ASC

-- w/ the limit per group condition enforced but syntax fuckery arrghhh
--v1
SELECT * FROM (SELECT MONTHNAME(APPOINTMENT) AS MONTH, ACCOUNTID, COUNT(DISTINCT PATIENTID) AS no_of_unique_patients, row_number() over (partition by MONTH ORDER BY no_of_unique_patients DESC) AS altcolumn FROM PATIENTLOGS) AS alttable WHERE altcolumn <= 2 ;

--v2
WITH alttable
AS (SELECT 
       MONTHNAME(APPOINTMENT) AS MONTH,
       ANY_VALUE(ACCOUNTID) AS ACCOUNTID,
       COUNT(DISTINCT PATIENTID) AS unique_patients,
       ROW_NUMBER() OVER (
          PARTITION BY MONTHNAME(APPOINTMENT) 
          ORDER BY COUNT(DISTINCT PATIENTID) DESC) row_num
    FROM 
       PATIENTLOGS
   )
SELECT 
   MONTH,
   ACCOUNTID,
   unique_patients
FROM 
   alttable
WHERE 
   row_num <= 2;

