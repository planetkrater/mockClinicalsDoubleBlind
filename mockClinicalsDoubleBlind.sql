-- --------------------------------------------------------------------------------
-- Author: Kate Wamsley
-- Abstract: Create a database for a mock clinical trails. The experiment is a double
--			 blind study, so both docter and patient do not know if their drug kit 
--			 contians the placebo or drug. The database will handle multiple studies 
--			 and test sites.  A patients information will be collected by the doctor
--			 at the 'screening phase' and a status will given to determine if the patient
--			 successing enters the 'randomization phase,' when a drug kit is assigned.
--			 A patient may enter the 'withdrawl phase' at any time in this process,
--			 when a withdrawl code is collected.  
-- 
--			 This database is designed to permit screened patients into the experiment,
--			 assign place or drug via a "drug kit" by randomization, and control the
--			 number and balance(placebo:drug) of patients allowed at each test site.
--
-- Script description: Core tables, relationships, inserts, views, procedures, 
--					   transactions, cursors, etc are established
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- Customers note: Allowing NULL or NOT NULL and using PK with association to the 
-- real world, up to the db-designer. Customer has no perference.
-- --------------------------------------------------------------------------------
-- ----------------------------------------------------------------- ---------------


-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;							-- Get out of the master database
SET NOCOUNT ON;						-- Report only errors

-- --------------------------------------------------------------------------------
-- Drop ALL Constraints, Tables, Views
-- --------------------------------------------------------------------------------
--	STORE PROCEDURES
IF OBJECT_ID ('uspScreenPatients')				IS NOT NULL DROP PROCEDURE uspScreenPatients;
IF OBJECT_ID ('uspRandomNum')					IS NOT NULL DROP PROCEDURE uspRandomNum;
IF OBJECT_ID ('uspGetTreatment54321')			IS NOT NULL DROP PROCEDURE uspGetTreatment54321;
IF OBJECT_ID ('uspGetPatientSiteID')			IS NOT NULL DROP PROCEDURE uspGetPatientSiteID;
IF OBJECT_ID ('uspGetDrugKit')					IS NOT NULL DROP PROCEDURE uspGetDrugKit;
IF OBJECT_ID ('uspGetRandomCode')				IS NOT NULL DROP PROCEDURE uspGetRandomCode;
IF OBJECT_ID ('uspUpdateTablesAfterRandomization')	IS NOT NULL DROP PROCEDURE uspUpdateTablesAfterRandomization;
IF OBJECT_ID ('uspStudyTreatmentRandomCode')	IS NOT NULL DROP PROCEDURE uspStudyTreatmentRandomCode;
IF OBJECT_ID ('uspPatientRandomization')		IS NOT NULL DROP PROCEDURE uspPatientRandomization;
--
IF OBJECT_ID ('uspWithdrawPatient')				IS NOT NULL DROP PROCEDURE uspWithdrawPatient;
IF OBJECT_ID ('uspValidateWithdraw')			IS NOT NULL DROP PROCEDURE uspValidateWithdraw;
--
IF OBJECT_ID ('uspVerifyPatient')				IS NOT NULL DROP PROCEDURE uspVerifyPatient;
IF OBJECT_ID ('uspVerifySite')					IS NOT NULL DROP PROCEDURE uspVerifySite;
IF OBJECT_ID ('uspVerifyVisitType')				IS NOT NULL DROP PROCEDURE uspVerifyVisitType;
IF OBJECT_ID ('uspAddPatient')					IS NOT NULL DROP PROCEDURE uspAddPatient;
IF OBJECT_ID ('uspAddPatientVisit')				IS NOT NULL DROP PROCEDURE uspAddPatientVisit;
--
IF OBJECT_ID ('uspDeleteANonRandPatient')		IS NOT NULL DROP PROCEDURE uspDeleteANonRandPatient;
IF OBJECT_ID ('uspDeleteARandPatient')			IS NOT NULL DROP PROCEDURE uspDeleteARandPatient;
IF OBJECT_ID ('uspVerifyAvailableStudyCodes')	IS NOT NULL DROP PROCEDURE uspVerifyAvailableStudyCodes;
--
IF OBJECT_ID ('uspCompleteNextPatientVisit')	IS NOT NULL DROP PROCEDURE uspCompleteNextPatientVisit;
--

--	VIEWS
IF OBJECT_ID ('VAllPatients')					IS NOT NULL DROP VIEW VAllPatients;
IF OBJECT_ID ('VAllPatientsRandomized')			IS NOT NULL DROP VIEW VAllPatientsRandomized;
IF OBJECT_ID ('VNextRandomCodeByStudy')			IS NOT NULL DROP VIEW VNextRandomCodeByStudy;
IF OBJECT_ID ('VAllAvailableDrugKits')			IS NOT NULL DROP VIEW VAllAvailableDrugKits;
IF OBJECT_ID ('VAllPatientsWithdrawn')			IS NOT NULL DROP VIEW VAllPatientsWithdrawn;
IF OBJECT_ID ('VAllPatientVisits')				IS NOT NULL DROP VIEW VAllPatientVisits;
IF OBJECT_ID ('VMostRecentPatientVisits')		IS NOT NULL DROP VIEW VMostRecentPatientVisits;
IF OBJECT_ID ('VPatientsToRandomize')			IS NOT NULL DROP VIEW VPatientsToRandomize;
IF OBJECT_ID ('VAllPatientsNonRandNonWith')		IS NOT NULL DROP VIEW VAllPatientsNonRandNonWith;
IF OBJECT_ID ('VAllPatientsRandNonWith')		IS NOT NULL DROP VIEW VAllPatientsRandNonWith;
IF OBJECT_ID ('VNextAvailableDrugKitBySite')	IS NOT NULL DROP VIEW VNextAvailableDrugKitBySite;
--

--	TABLES
IF OBJECT_ID ('TDrugKits')						IS NOT NULL DROP TABLE TDrugKits;
IF OBJECT_ID ('TPatientVisits')					IS NOT NULL DROP TABLE TPatientVisits;
IF OBJECT_ID ('TPatients')						IS NOT NULL DROP TABLE TPatients;
IF OBJECT_ID ('TSites')							IS NOT NULL DROP TABLE TSites;
IF OBJECT_ID ('TRandomCodes')					IS NOT NULL DROP TABLE TRandomCodes;
IF OBJECT_ID ('TStudies')						IS NOT NULL DROP TABLE TStudies;
IF OBJECT_ID ('TVisitTypes')					IS NOT NULL DROP TABLE TVisitTypes;
IF OBJECT_ID ('TWithdrawReasons')				IS NOT NULL DROP TABLE TWithdrawReasons;

-- --------------------------------------------------------------------------------
-- 
-- 
-- 
-- 
-- 
--
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- TABLES
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
CREATE TABLE TStudies
(
	 intStudyID						INTEGER		NOT NULL		--*	(1,2)
	,strStudyDesc					VARCHAR(50)	NOT NULL
	,CONSTRAINT TStudies_PK PRIMARY KEY ( intStudyID )
);

CREATE TABLE TSites
(
	 intSiteID						INTEGER		NOT NULL		--*	(101, 102, 103, etc.)
	,intStudyID						INTEGER		NOT NULL 
	,strName 						VARCHAR(50)	NOT NULL
	,strAddress						VARCHAR(50)	NOT NULL 
	,strCity						VARCHAR(50)	NOT NULL 
	,strState						VARCHAR(50)	NOT NULL 
	,strZip							VARCHAR(50)	NOT NULL 
	,strPhone						VARCHAR(50)	NOT NULL 
	,CONSTRAINT TSites_PK PRIMARY KEY ( intSiteID )
);

CREATE TABLE TPatients
(
	 intPatientID					INTEGER		NOT NULL		--*	(101001, 102001, etc)
	,intSiteID 						INTEGER		NOT NULL
	,dtmDOB 						DATETIME	NOT NULL
	,intGenderID 					INTEGER		NOT NULL
	,intWeight						INTEGER		NOT NULL
	,intRandomCodeID				INTEGER						--allow Nulls
	,CONSTRAINT TPatients_PK PRIMARY KEY ( intPatientID )
);


CREATE TABLE TVisitTypes
(
	 intVisitTypeID					INTEGER		NOT NULL		--* (1,2,3)
	,strVisitDesc					VARCHAR(50)	NOT NULL		--(Screening, Randomization, Withdrawal)
	,CONSTRAINT TVisitTypes_PK PRIMARY KEY ( intVisitTypeID )
);

CREATE TABLE TPatientVisits
(
	 intVisitID						INTEGER		NOT NULL		--*	(1,2,3,etc.)
	,intPatientID					INTEGER		NOT NULL
	,dtmVisit						DATETIME	NOT NULL
	,intVisitTypeID					INTEGER		NOT NULL
	,intWithdrawReasonID			INTEGER						--allow Nulls
	,CONSTRAINT TPatientVisits_PK PRIMARY KEY ( intVisitID )
);

CREATE TABLE TRandomCodes
(
	 intRandomCodeID				INTEGER		NOT NULL		--*	(1000, 1001, 1002, etc.)
	,intStudyID 					INTEGER		NOT NULL
	,strTreatment					VARCHAR(50)	NOT NULL		--(A-active or P-placebo)
	,blnAvailable					BIT			NOT NULL		--(T or F)
	,CONSTRAINT TRandomCodes_PK PRIMARY KEY ( intRandomCodeID )
);

CREATE TABLE TDrugKits
(
	 intDrugKitID					INTEGER		NOT NULL		--*	(10000, 10001, 10002, etc.)
	,intSiteID						INTEGER		NOT NULL
	,strTreatment					VARCHAR(50)	NOT NULL		--(A-active or P-placebo)
	,intVisitID						INTEGER						--(if a Visit ID entered it is already assigned and therefore not available) 
																--allow Nulls
	,CONSTRAINT TDrugKits_PK PRIMARY KEY ( intDrugKitID )
);

CREATE TABLE TWithdrawReasons
(
	 intWithdrawReasonID			INTEGER		NOT NULL		--* (1,2,3,etc.)
	,strWithdrawDesc				VARCHAR(50)	NOT NULL
	,CONSTRAINT TWithdrawReasons_PK PRIMARY KEY ( intWithdrawReasonID )
);



-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- FOREIGN KEYS
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
--		Child					Parent			        Column(s)
--		-----					------		        	---------
-- 1    TSites					TStudies				intStudyID

-- 2    TPatients				TSites					intSiteID
-- 3    TPatients				TRandomCodes			intRandomCodeID

-- 4    TPatientVisits			TPatients				intPatientID
-- 5    TPatientVisits			TVisitTypes				intVisitTypeID
-- 6    TPatientVisits			TWithdrawReasons		intWithdrawReasonID

-- 7	TDrugKits				TSites					intSiteID
-- 8	TDrugKits				TPatientVisits			intVisitID

-- 1
ALTER TABLE TSites ADD CONSTRAINT TSites_TStudies_FK
FOREIGN KEY ( intStudyID ) REFERENCES TStudies ( intStudyID  );

-- 2
ALTER TABLE TPatients ADD CONSTRAINT TPatients_TSites_FK
FOREIGN KEY ( intSiteID ) REFERENCES TSites ( intSiteID  );
-- 3
ALTER TABLE TPatients ADD CONSTRAINT TPatients_TRandomCodes_FK
FOREIGN KEY ( intRandomCodeID ) REFERENCES TRandomCodes ( intRandomCodeID  );

-- 4
ALTER TABLE TPatientVisits ADD CONSTRAINT TPatientVisits_TPatients_FK
FOREIGN KEY ( intPatientID ) REFERENCES TPatients ( intPatientID  );
-- 5
ALTER TABLE TPatientVisits ADD CONSTRAINT TPatientVisits_TVisitTypes_FK
FOREIGN KEY ( intVisitTypeID ) REFERENCES TVisitTypes ( intVisitTypeID  );
-- 6
ALTER TABLE TPatientVisits ADD CONSTRAINT TPatientVisits_TWithdrawReasons_FK
FOREIGN KEY ( intWithdrawReasonID ) REFERENCES TWithdrawReasons ( intWithdrawReasonID  );

-- 7
ALTER TABLE TDrugKits ADD CONSTRAINT TDrugKits_TSites_FK
FOREIGN KEY ( intSiteID ) REFERENCES TSites ( intSiteID  );
-- 8
ALTER TABLE TDrugKits ADD CONSTRAINT TDrugKits_TPatientVisits_FK
FOREIGN KEY ( intVisitID ) REFERENCES TPatientVisits ( intVisitID  );



-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- INSERTS										(static data only --> NO patients)
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
INSERT INTO TStudies ( intStudyID, strStudyDesc )
VALUES	 ( 12345, 'Study 1' )
		,( 54321, 'Study 2' );

INSERT INTO TVisitTypes ( intVisitTypeID, strVisitDesc )
VALUES	 ( 1, 'Screening' )
		,( 2, 'Randomization' )
		,( 3, 'Withdrawal' );

INSERT INTO TSites ( intSiteID, intStudyID, strName, strAddress  , strCity , strState , strZip , strPhone )
VALUES	 (101, 12345, 'Dr. Stan Heinrich ', '123 E. Main St' , 'Atlanta', 'GA', '25869', '1234567890' )
		,(111, 12345, 'Mercy Hospital', '3456 Elmhurst Rd.' , 'Secaucus', 'NJ', '32659', '5013629564' )
		,(121, 12345, 'St. Elizabeth Hospital', '976 Jackson Way' , 'Ft. Thomas', 'KY', '41258', '3026521478' )
		,(131, 12345, 'Dr. Jim Smith', '32454 Morris Rd.' , 'Hamilton', 'OH', '45013', '3256847596' )
		,(141, 12345, 'Dr. Dan Jones', '1865 Jelico Hwy.' , 'Knoxville', 'TN', '34568', '2145798241' )
		,(501, 54321, 'Dr. Robert Adler', '9087 W. Maple Ave.' , 'Cedar Rapids', 'IA', '42365', '6149652574' )
		,(511, 54321, 'Dr. Tim Schmitz', '4539 Helena Run' , 'Johnson City', 'TN', '34785', '5066987462' )
		,(521, 54321, 'Dr. Lawrence Snell', '9201 NW. Washington Blvd.' , 'Bristol', 'VA', '20163', '3876510249' )
		,(531, 54321, 'Cedar Sinai Medical Center', '40321 Hollywood Blvd.' , 'Portland', 'OR', '50236', '5439510246' )
		,(541, 54321, 'Vally View Hospital', '398 Hampton Rd.' , 'Seattle', 'WA', '41203', '7243780036' );

INSERT INTO TRandomCodes ( intRandomCodeID, intStudyID , strTreatment, blnAvailable )
VALUES	 (1000, 12345, 'A', 1 )
		,(1001, 12345, 'P', 1 )
		,(1002, 12345, 'A', 1 )
		,(1003, 12345, 'P', 1 )
		,(1004, 12345, 'P', 1 )
		,(1005, 12345, 'A', 1 )
		,(1006, 12345, 'A', 1 )
		,(1007, 12345, 'P', 1 )
		,(1008, 12345, 'A', 1 )
		,(1009, 12345, 'P', 1 )
		,(1010, 12345, 'P', 1 )
		,(1011, 12345, 'A', 1 )
		,(1012, 12345, 'P', 1 )
		,(1013, 12345, 'A', 1 )
		,(1014, 12345, 'A', 1 )
		,(1015, 12345, 'A', 1 )
		,(1016, 12345, 'P', 1 )
		,(1017, 12345, 'P', 1 )
		,(1018, 12345, 'A', 1 )
		,(1019, 12345, 'P', 1 )
		,(5000, 54321, 'A', 1 )
		,(5001, 54321, 'A', 1 )
		,(5002, 54321, 'A', 1 )
		,(5003, 54321, 'A', 1 )
		,(5004, 54321, 'A', 1 )
		,(5005, 54321, 'A', 1 )
		,(5006, 54321, 'A', 1 )
		,(5007, 54321, 'A', 1 )
		,(5008, 54321, 'A', 1 )
		,(5009, 54321, 'A', 1 )
		,(5010, 54321, 'P', 1 )
		,(5011, 54321, 'P', 1 )
		,(5012, 54321, 'P', 1 )
		,(5013, 54321, 'P', 1 )
		,(5014, 54321, 'P', 1 )
		,(5015, 54321, 'P', 1 )
		,(5016, 54321, 'P', 1 )
		,(5017, 54321, 'P', 1 )
		,(5018, 54321, 'P', 1 )
		,(5019, 54321, 'P', 1 );

INSERT INTO TDrugKits ( intDrugKitID, intSiteID, strTreatment )
VALUES	 (10000, 101, 'A' )
		,(10001, 101, 'A' )
		,(10002, 101, 'A' )
		,(10003, 101, 'A' )
		,(10004, 101, 'P' )
		,(10005, 101, 'P' )
		,(10006, 101, 'P' )
		,(10007, 101, 'P' )
		,(10008, 111, 'A' )
		,(10009, 111, 'A' )
		,(10010, 111, 'A' )
		,(10011, 111, 'A' )
		,(10012, 111, 'P' )
		,(10013, 111, 'P' )
		,(10014, 111, 'P' )
		,(10015, 111, 'P' )
		,(10016, 121, 'A' )
		,(10017, 121, 'A' )
		,(10018, 121, 'A' )
		,(10019, 121, 'A' )
		,(10020, 121, 'P' )
		,(10021, 121, 'P' )
		,(10022, 121, 'P' )
		,(10023, 121, 'P' )
		,(10024, 131, 'A' )
		,(10025, 131, 'A' )
		,(10026, 131, 'A' )
		,(10027, 131, 'A' )
		,(10028, 131, 'P' )
		,(10029, 131, 'P' )
		,(10030, 131, 'P' )
		,(10031, 131, 'P' )
		,(10032, 141, 'A' )
		,(10033, 141, 'A' )
		,(10034, 141, 'A' )
		,(10035, 141, 'A' )
		,(10036, 141, 'P' )
		,(10037, 141, 'P' )
		,(10038, 141, 'P' )
		,(10039, 141, 'P' )
		,(10040, 501, 'A' )
		,(10041, 501, 'A' )
		,(10042, 501, 'A' )
		,(10043, 501, 'A' )
		,(10044, 501, 'P' )
		,(10045, 501, 'P' )
		,(10046, 501, 'P' )
		,(10047, 501, 'P' )
		,(10048, 511, 'A' )
		,(10049, 511, 'A' )
		,(10050, 511, 'A' )
		,(10051, 511, 'A' )
		,(10052, 511, 'P' )
		,(10053, 511, 'P' )
		,(10054, 511, 'P' )
		,(10055, 511, 'P' )
		,(10056, 521, 'A' )
		,(10057, 521, 'A' )
		,(10058, 521, 'A' )
		,(10059, 521, 'A' )
		,(10060, 521, 'P' )
		,(10061, 521, 'P' )
		,(10062, 521, 'P' )
		,(10063, 521, 'P' )
		,(10064, 531, 'A' )
		,(10065, 531, 'A' )
		,(10066, 531, 'A' )
		,(10067, 531, 'A' )
		,(10068, 531, 'P' )
		,(10069, 531, 'P' )
		,(10070, 531, 'P' )
		,(10071, 531, 'P' )
		,(10072, 541, 'A' )
		,(10073, 541, 'A' )
		,(10074, 541, 'A' )
		,(10075, 541, 'A' )
		,(10076, 541, 'P' )
		,(10077, 541, 'P' )
		,(10078, 541, 'P' )
		,(10079, 541, 'P' );

INSERT INTO TWithdrawReasons ( intWithdrawReasonID, strWithdrawDesc )
VALUES	 ( 1, 'Patient withdrew consent' )
		,( 2, 'Adverse event' )
		,( 3, 'Health issue-related to study' )
		,( 4, 'Health issue-unrelated to study' )
		,( 5, 'Personal reason' )
		,( 6, 'Completed the study' );



-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- VIEWS
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- V.1: All patients at all sites for both studies. 
--		You can do this together or 1 view for each study.
-- --------------------------------------------------------------------------------
GO
CREATE VIEW VAllPatients
AS
SELECT
	 TStu.intStudyID
	,TStu.strStudyDesc
	,TSi.intSiteID
	,TSi.strName
	,TP.intPatientID
	,CAST(TP.dtmDOB AS DATE) AS 'dteDOB'
	,TP.intGenderID
	,TP.intWeight
	,TP.intRandomCodeID
	,TRC.strTreatment
FROM
	TStudies AS TStu
		LEFT OUTER JOIN TSites AS TSi
			LEFT OUTER JOIN TPatients AS TP
				LEFT OUTER JOIN TRandomCodes AS TRC
				ON TP.intRandomCodeID = TRC.intRandomCodeID
			ON TSi.intSiteID = TP.intSiteID	
		ON TStu.intStudyID = TSi.intStudyID
GO



-- --------------------------------------------------------------------------------
-- V.2: All randomized patients, their site and their treatment for both studies. 
--		You can do this together or 1 view for each study.
-- --------------------------------------------------------------------------------
GO
CREATE VIEW VAllPatientsRandomized
AS
SELECT
	*
FROM
	VAllPatients
WHERE
	intRandomCodeID IS NOT NULL

GO		



-- --------------------------------------------------------------------------------
-- V.3: Next available random codes (MIN) for both studies.
--		You can do this together or 1 view for each study.
-- --------------------------------------------------------------------------------
GO
CREATE VIEW VNextRandomCodeByStudy
AS
SELECT	
	 TCount.intStudyID
	,TCount.intNextRandomCodeID
	,TCount.strTreatment
	,(TCount.intTreatmentCount*2) - TTotal.intTreatmentTotal AS intTreatmentGain
FROM 
	(	SELECT
			 intStudyID
			,MIN( intRandomCodeID ) AS intNextRandomCodeID
			,strTreatment
			,COUNT(strTreatment)	AS intTreatmentCount
		FROM
			TRandomCodes
		WHERE 
			blnAvailable = 1
		GROUP BY
			 intStudyID
			,strTreatment
	) AS TCount
	INNER JOIN 
		(	SELECT	
				 intStudyID
				,COUNT(strTreatment)	AS intTreatmentTotal
			FROM
				TRandomCodes
			WHERE 
				blnAvailable = 1
			GROUP BY
				 intStudyID
		) AS TTotal
	ON TCount.intStudyID = TTotal.intStudyID

GO



-- --------------------------------------------------------------------------------
-- V.4: All available drugs at all sites for both studies. 
--		You can do this together or 1 view for each study.
-- --------------------------------------------------------------------------------
GO
CREATE VIEW VAllAvailableDrugKits
AS
SELECT
	intDrugKitID
	,intSiteID
	,strTreatment
	,intVisitID
FROM
	TDrugKits
WHERE
	intVisitID IS NULL
GO



-- --------------------------------------------------------------------------------
-- V.5: Next Drug Kit available for each treatment at each site
-- --------------------------------------------------------------------------------
GO
CREATE VIEW VNextAvailableDrugKitBySite
AS
SELECT
	 MIN(intDrugKitID)	AS intNextDrugKitID
	,intSiteID
	,strTreatment
FROM
	VAllAvailableDrugKits
GROUP BY
	 intSiteID
	,strTreatment
	,intVisitID

GO



-- --------------------------------------------------------------------------------
-- V.6: All withdrawn patients, their site, withdrawal date and withdrawal reason for both studies.
-- --------------------------------------------------------------------------------
GO
CREATE VIEW VAllPatientsWithdrawn
AS
SELECT
	 VAP.intStudyID
	,VAP.strStudyDesc
	,VAP.intSiteID
	,VAP.strName
	,VAP.intPatientID
	,TWR.intWithdrawReasonID
	,TWR.strWithdrawDesc
FROM
	VAllPatients AS VAP
		LEFT OUTER JOIN TPatientVisits AS TPV
			INNER JOIN TWithdrawReasons AS TWR
			ON TPV.intWithdrawReasonID = TWR.intWithdrawReasonID
		ON VAP.intPatientID = TPV.intPatientID
WHERE
	TWR.intWithdrawReasonID IS NOT NULL


GO



-- --------------------------------------------------------------------------------
-- V.7: All Patient Visits at all sites
-- --------------------------------------------------------------------------------
GO
CREATE VIEW VAllPatientVisits
AS
SELECT
	 VAP.intStudyID
	,VAP.strStudyDesc
	,VAP.intSiteID
	,VAP.strName
	,VAP.intPatientID
	,VAP.intRandomCodeID
	,VAP.strTreatment	
	,TPV.intVisitID
	,CAST(TPV.dtmVisit AS DATE)			AS dteVisit
	,TPV.intVisitTypeID
	,TWR.intWithdrawReasonID
	,TWR.strWithdrawDesc
FROM
	VAllPatients AS VAP
		LEFT OUTER JOIN TPatientVisits AS TPV
			LEFT OUTER JOIN TWithdrawReasons AS TWR
			ON TPV.intWithdrawReasonID = TWR.intWithdrawReasonID
		ON VAP.intPatientID = TPV.intPatientID
WHERE
	VAP.intPatientID IS NOT NULL

GO



-- --------------------------------------------------------------------------------
-- V.8: Most recent visit of each Patient at all sites
-- --------------------------------------------------------------------------------
GO
CREATE VIEW VMostRecentPatientVisits
AS

SELECT
	 VAPV.intStudyID
	,VAPV.strStudyDesc
	,VAPV.intSiteID
	,VAPV.strName
	,VAPV.intPatientID	
	,VAPV.intRandomCodeID
	,VAPV.strTreatment
	,VAPV.intVisitID
	,VAPV.dteVisit
	,VAPV.intVisitTypeID
	,VAPV.intWithdrawReasonID
	,VAPV.strWithdrawDesc
FROM 
	VAllPatientVisits AS VAPV
	-- Amend most recent date with the rest of the visit information
		INNER JOIN	(	-- Get the date of the most recent visit
						SELECT
							 intStudyID	
							,intPatientID
							,MAX(intVisitTypeID)	AS intMostRecentVisitType
						FROM
							(	SELECT		 
									 intStudyID	
									,intPatientID
									,MAX(dteVisit)		AS dteVisitMostRecent
									,intVisitTypeID
								FROM
									VAllPatientVisits
								GROUP BY
									 intStudyID	
									,intPatientID
									,intVisitTypeID
							) AS VMostRecentVisits
						GROUP BY
							 intStudyID	
							,intPatientID
					) AS VMostRecentVisitType		
		ON	VAPV.intStudyID = VMostRecentVisitType.intStudyID
		AND VAPV.intPatientID = VMostRecentVisitType.intPatientID
		AND VAPV.intVisitTypeID = VMostRecentVisitType.intMostRecentVisitType

GO



-- --------------------------------------------------------------------------------
-- V.9:	Use most recent visit of each Patient at all sites to select
--		Patients ready to be Randomized - no random code, no withdrawl code
-- --------------------------------------------------------------------------------
GO
CREATE VIEW VPatientsToRandomize
AS
SELECT
	 intStudyID
	,intPatientID
	,intVisitID
	,dteVisit
FROM
	VMostRecentPatientVisits
WHERE
	intVisitTypeID = 2			-- Passed screening
AND intRandomCodeID IS NULL		-- Not already randomized
AND intWithdrawReasonID IS NULL	-- Not already withdrawn

GO


-- --------------------------------------------------------------------------------
-- V.10: Use most recent visit of each Patient at all sites to select
--		 Patients with no random code, no withdrawl code
-- --------------------------------------------------------------------------------
GO
CREATE VIEW VAllPatientsNonRandNonWith
AS
SELECT 
	 VAllPatientVisits.intStudyID
	,VAllPatientVisits.intPatientID
	,VAllPatientVisits.intRandomCodeID
	,VAllPatientVisits.intVisitTypeID
	,VAllPatientVisits.intWithdrawReasonID
FROM
	VAllPatientVisits
		INNER JOIN (SELECT
						intPatientID
						,MAX(dteVisit) AS dteMostRecentVisit
					FROM
						VAllPatientVisits
					GROUP BY
						intPatientID
					) AS VAPV
		ON VAllPatientVisits.intPatientID = VAPV.intPatientID
		AND	  VAllPatientVisits.dteVisit = VAPV.dteMostRecentVisit
WHERE
	NOT EXISTS 
	(	SELECT intPatientID
		FROM VAllPatientsRandomized 
		WHERE VAllPatientVisits.intPatientID = VAllPatientsRandomized.intPatientID
		UNION
		SELECT intPatientID
		FROM VAllPatientsWithdrawn
		WHERE VAllPatientVisits.intPatientID = VAllPatientsWithdrawn.intPatientID		
	)
AND VAllPatientVisits.intPatientID IS NOT NULL
GO



-- --------------------------------------------------------------------------------
-- V.11: Use most recent visit of each Patient at all sites to select
--		 Patients with random code, no withdrawl code
-- --------------------------------------------------------------------------------
GO
CREATE VIEW VAllPatientsRandNonWith
AS
SELECT 
	 VAllPatientVisits.intStudyID
	,VAllPatientVisits.intPatientID
	,VAllPatientVisits.intRandomCodeID
	,VAllPatientVisits.intVisitTypeID
	,VAllPatientVisits.intWithdrawReasonID
FROM
	VAllPatientVisits
		INNER JOIN (SELECT
						intPatientID
						,MAX(dteVisit) AS dteMostRecentVisit
					FROM
						VAllPatientVisits
					GROUP BY
						intPatientID
					) AS VAPV
		ON VAllPatientVisits.intPatientID = VAPV.intPatientID
		AND	  VAllPatientVisits.dteVisit = VAPV.dteMostRecentVisit
WHERE
	EXISTS 
	(	SELECT intPatientID
		FROM VAllPatientsRandomized AS VAPR
		WHERE 
			NOT EXISTS 
				(	SELECT intPatientID
					FROM VAllPatientsWithdrawn AS VAPW
					WHERE VAPR.intPatientID = VAPW.intPatientID
				)
		AND VAPV.intPatientID = VAPR.intPatientID
				
	)
GO


-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
--	STORED PROCEDURES
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- SP.1: Screen a patient for both studies. 
--		 You can do this together or 1 for each study.
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspScreenPatients
	 @intStudyID	AS INTEGER OUTPUT
	,@intPatientID AS INTEGER OUTPUT
AS	
SET NOCOUNT ON
SET XACT_ABORT ON

-- Select first patient in line to be randomized
SELECT TOP (1)					
	 @intStudyID	= intStudyID
	,@intPatientID = intPatientID
FROM VPatientsToRandomize
	
GO


-- --------------------------------------------------------------------------------
-- SP.2: Randomize a patient for both studies. This will include a stored procedure 
--		 for obtaining a random code as well as a drug kit.
--		 You can do this together or 1 for each study.		  
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- SP.2.1: Get a Random number, simplify it to 0 or 1
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspRandomNum
		@intRandom		AS DECIMAL(10,2)
AS
SET NOCOUNT ON;

-- Get random number 0 - 1 
SELECT	@intRandom = RAND();

-- Simplify number to 0 OR 1
IF @intRandom > 0.5
	RETURN 1
ELSE IF @intRandom <= 0.5
	RETURN 0
GO -- Returned number always 1 or 0



-- --------------------------------------------------------------------------------
-- SP.2.2: Determine the next treatment for Study 54321 randomization
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspGetTreatment54321
		 @intRandom		AS INTEGER
		,@intStudyID	AS INTEGER
AS
SET NOCOUNT ON;	

DECLARE	 @intGain		AS INTEGER

-- Find the ratio of available A:P -- Gain of 'A' = 'A' - 'P'
SELECT
	 @intGain = intTreatmentGain
FROM
	VNextRandomCodeByStudy
WHERE
	intStudyID = @intStudyID
AND strTreatment = 'A';

-- Let Gain determine treatment
IF @intGain >= 2		-- At 2 limit max of A
	RETURN 0				-- P
ELSE IF @intGain <= -2	-- At 2 limit max of P
	RETURN 1				-- A
ELSE					-- Not at limit, use random number selection
	RETURN @intRandom		-- P (0), A (1) 
GO -- Returned number always 1 or 0



-- --------------------------------------------------------------------------------
-- SP.2.3: Get the Patient's SiteID
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspGetPatientSiteID
		@intPatientID	AS INTEGER
AS
SET NOCOUNT ON;	

DECLARE @intSiteID	AS INTEGER = - 1

-- Get Patient's SiteID
SELECT
	@intSiteID = intSiteID
FROM
	VAllPatients
WHERE
	intPatientID = @intPatientID

RETURN @intSiteID
GO -- Return value default(-1) or Site value returned



-- --------------------------------------------------------------------------------
-- SP.2.4: Determine the next drug kit for both studies
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspGetDrugKit
		 @intPatientID	AS INTEGER
		,@strTreatment	AS VARCHAR(50)
		,@intSiteID		AS INTEGER
AS
SET NOCOUNT ON;	

DECLARE  @intDrugKit	AS INTEGER = - 1

-- Get Next DrugKitID for Patient's Site and Treatment
SELECT	
	@intDrugKit = intNextDrugKitID
FROM
	VNextAvailableDrugKitBySite
WHERE
	intSiteID = @intSiteID
AND strTreatment = @strTreatment

-- Return result
RETURN @intDrugKit

GO -- Return value default(-1) or Kit value returned



-- --------------------------------------------------------------------------------
-- SP.2.5: Determine the next random code for both studies
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspGetRandomCode
		 @intStudyID	AS INTEGER
		,@strTreatment	AS VARCHAR(5)
AS
SET NOCOUNT ON;	

DECLARE  @intRandomCode	AS INTEGER = - 1

-- Get the next random code available for Study and treatment
SELECT
	 @intRandomCode = intNextRandomCodeID
FROM
	VNextRandomCodeByStudy
WHERE
	intStudyID = @intStudyID
AND strTreatment = @strTreatment;

RETURN @intRandomCode
GO -- Return value default(-1) or RandomCode value returned



-- --------------------------------------------------------------------------------
-- SP.2.6: Update TPatients, TRandomCodes, TDrugKits for both studies
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspUpdateTablesAfterRandomization
		 @intPatientID	AS INTEGER
		,@intDrugKitID	AS INTEGER
		,@intRandomCode AS INTEGER
AS
SET NOCOUNT ON;			--Report only errors
SET XACT_ABORT ON;		--Terminate and rollback entire transaction on error

DECLARE  @intVisitID	AS INTEGER = -1

-- Get VisitID for Patient Visit at Current Screening
SELECT
	@intVisitID = intVisitID
FROM 
	VPatientsToRandomize
WHERE
	intPatientID = @intPatientID

BEGIN TRANSACTION
	UPDATE TDrugKits
	SET intVisitID = @intVisitID
	WHERE intDrugKitID = @intDrugKitID

	UPDATE TRandomCodes 
	SET blnAvailable =0
	WHERE intRandomCodeID = @intRandomCode;	

	UPDATE TPatients
	SET intRandomCodeID = @intRandomCode
	WHERE intPatientID = @intPatientID

	PRINT 'Patient (' + CONVERT(VARCHAR(10), @intPatientID) + '), Random Code (' + CONVERT(VARCHAR(10), @intRandomCode) + '), Drug Kit (' + CONVERT(VARCHAR(10), @intDrugKitID) + ') have been updated.'

COMMIT TRANSACTION;
GO



-- --------------------------------------------------------------------------------
-- SP.2.7: Queue to randomize a patient for both studies
--		Step 1) Get treatment  - A or P
--		Step 2) Get drug kit
--		Step 3) Get random code
--		Step 4) UPDATE TABLES and/or report errors/success to user
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspStudyTreatmentRandomCode
		 @intStudyID	AS INTEGER
		,@intPatientID	AS INTEGER
AS
SET NOCOUNT ON;

DECLARE  @intRandom		AS INTEGER
DECLARE  @intSiteID		AS INTEGER
DECLARE  @intTreatment	AS INTEGER
DECLARE  @strTreatment	AS VARCHAR(5)
DECLARE  @intDrugKit	AS INTEGER = - 1
DECLARE  @intRandomCode AS INTEGER = - 1

-- Get random number
EXEC @intRandom = uspRandomNum @intRandom

-- Get SiteID of Patient
EXEC @intSiteID = uspGetPatientSiteID @intPatientID

-- Get the next treatment for study
IF @intStudyID = 12345 
	SELECT @intTreatment = @intRandom
ELSE IF @intStudyID = 54321
	EXEC @intTreatment = uspGetTreatment54321 @intRandom, @intStudyID

-- Convert intTreatment to strTreatment
IF @intTreatment = 1
	SELECT @strTreatment = 'P'
ELSE IF @intTreatment = 0
	SELECT @strTreatment = 'A'

-- Get a drug kit
EXEC @intDrugKit = uspGetDrugKit @intPatientID, @strTreatment, @intSiteID
-- Was a drugkit returned?
IF @intDrugKit = - 1
	BEGIN
	-- No, try other treatment
		IF @intTreatment = 1
			BEGIN
				SELECT @intTreatment = 0
				SELECT @strTreatment = 'A'
			END
		ELSE IF @intTreatment = 0
			BEGIN
				SELECT @intTreatment = 1
				SELECT @strTreatment = 'P'
			END
		EXEC @intDrugKit = uspGetDrugKit @intPatientID, @strTreatment, @intSiteID
	END
-- Was a drugkit returned?
IF @intDrugKit = - 1
	-- No, warn user
		PRINT 'Cannot retrieve Drug Kit for Patient (' + CONVERT(VARCHAR(10), @intPatientID) + ') at their study site (' + CONVERT(VARCHAR(10), @intSiteID) + ').'
ELSE IF @intDrugKit <> - 1
	-- Yes, get RandomCode
	EXEC @intRandomCode = uspGetRandomCode @intStudyID, @strTreatment

IF @intTreatment = - 1 OR @intDrugKit = - 1 OR @intRandomCode = - 1
	PRINT 'Cannot retrieve RandomCode for Patient (' + CONVERT(VARCHAR(10), @intPatientID) + ') at their study site (' + CONVERT(VARCHAR(10), @intSiteID) + ').'
ELSE
	EXEC uspUpdateTablesAfterRandomization @intPatientID, @intDrugKit, @intRandomCode
PRINT ' '
GO



-- --------------------------------------------------------------------------------
-- SP.2.8: et each patient to be randomized one by one, send through randomization process
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspPatientRandomization
AS
SET NOCOUNT ON

DECLARE @intStudyID		AS INTEGER;
DECLARE @intPatientID	AS INTEGER; 

DECLARE StudyCursor CURSOR LOCAL FOR
	SELECT 
		 intStudyID
		,intPatientID 
	FROM VPatientsToRandomize
	WHERE dteVisit = CONVERT(DATE, GETDATE())  -- The visit date will be recorded as the current date


OPEN StudyCursor
	-- Get Patient/Study to randomize, put into local variables
	FETCH NEXT FROM StudyCursor
		INTO @intStudyID, @intPatientID	
	WHILE @@FETCH_STATUS = 0
		BEGIN
		-- Execute procedures to get treatment and random codes
			EXEC uspStudyTreatmentRandomCode @intStudyID, @intPatientID
			-- Get next	Patient/Study
			FETCH NEXT FROM StudyCursor
				INTO @intStudyID, @intPatientID			
		END
CLOSE StudyCursor

DEALLOCATE StudyCursor

GO



-- --------------------------------------------------------------------------------
-- SP.3:  Withdraw a patient for both studies. Remember a patient can go from Screening
--		  Visit to Withdrawal without being randomized. This will be up to the Doctor.
--	      Your code just has to be able to do it.
--		  You can do this together or 1 for each study.
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- SP.3.1: Validate if WithdrawReason exists
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspValidateWithdraw
		 @intPatientID	AS INTEGER
		,@intWithdrawReasonID AS INTEGER
AS
SET NOCOUNT ON

DECLARE  @blnValid		AS BIT		= 0

-- Verify patient ID
SELECT	
	@blnValid = 1
FROM 
	TPatients
WHERE
	intPatientID = @intPatientID

IF @blnValid = 0
	BEGIN
		PRINT 'Patient (' + CONVERT(VARCHAR(10), @intPatientID) + ') is invalid. Withdraw process for Patient (' + CONVERT(VARCHAR(10), @intPatientID) + ') was terminated.'
		RETURN @blnValid
	END

-- Reset validation
SELECT @blnValid = 0

-- Verify withdraw reason
SELECT	
	@blnValid = 1
FROM 
	TWithdrawReasons
WHERE
	intWithdrawReasonID = @intWithdrawReasonID

IF @blnValid = 0
	PRINT 'Withdraw Reason (' + CONVERT(VARCHAR(5), @intWithdrawReasonID) + ') is invalid. Withdraw process for Patient (' + CONVERT(VARCHAR(10), @intPatientID) + ') was terminated.'

RETURN @blnValid
GO



-- --------------------------------------------------------------------------------
-- SP.3.2: Withdraw the given patient using given withdrawn date
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspWithdrawPatient
		 @intPatientID	AS INTEGER OUTPUT
		,@intWithdrawReasonID AS INTEGER
AS
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE	 @intVisitID	AS INTEGER
DECLARE	 @dtmCurrent	AS DATETIME
DECLARE	 @intVisitTypeID AS INTEGER = 3
DECLARE  @blnValid		AS BIT		= 0 -- false

-- Verify given patientID and withddrawreasonID are valid
EXEC @blnValid = uspValidateWithdraw @intPatientID, @intWithdrawReasonID

IF @blnValid > 0
	BEGIN 
		-- Yes, valid patientID and withddrawreasonID
		BEGIN TRANSACTION

		-- Next available VisitID
		SELECT
			@intVisitID = COALESCE( ( MAX( intVisitID ) + 1 ), 1)
		FROM
			TPatientVisits (TABLOCKX);	--Lock table until end of transaction

		-- Get current date and time
		SELECT @dtmCurrent = GETDATE()

		-- Insert into TPatientVisits
		INSERT INTO TPatientVisits ( intVisitID, intPatientID, dtmVisit, intVisitTypeID, intWithdrawReasonID )
		VALUES ( @intVisitID, @intPatientID, @dtmCurrent, @intVisitTypeID, @intWithdrawReasonID);

		PRINT 'Patient (' + CONVERT(VARCHAR(10), @intPatientID) + ') was successfully withdrawn during Visit (' + CONVERT(VARCHAR(10), @intVisitID)  + ') and using Withdraw Reason (' + CONVERT(VARCHAR(5), @intWithdrawReasonID) + ').'
	
		COMMIT TRANSACTION;
	END

PRINT ' '
GO



-- --------------------------------------------------------------------------------
-- SP.3.3: Verify Patient exists
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspVerifyPatient
		 @intPatientID	AS INTEGER
AS
SET NOCOUNT ON;		--Report only errors

DECLARE  @blnValid		AS BIT		= 0

-- Verify patient ID
SELECT	
	@blnValid = 1
FROM 
	TPatients
WHERE
	intPatientID = @intPatientID
	
RETURN @blnValid
GO -- true (1) patient exists



-- --------------------------------------------------------------------------------
-- SP.3.4: Verify site exists
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspVerifySite
		@intSiteID		AS INTEGER
AS
SET NOCOUNT ON;		--Report only errors

DECLARE  @blnValid		AS BIT		= 0

-- Verify site
SELECT	
	@blnValid = 1					-- true, site exists
FROM 
	TSites
WHERE
	intSiteID = @intSiteID


RETURN @blnValid
GO



-- --------------------------------------------------------------------------------
-- SP.3.5: Verify visit type exists
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspVerifyVisitType
		@intVisitTypeID		AS INTEGER
AS
SET NOCOUNT ON;		--Report only errors

DECLARE  @blnValid		AS BIT		= 0

-- Verify site
SELECT	
	@blnValid = 1					-- true, site exists
FROM 
	TVisitTypes
WHERE
	intVisitTypeID = @intVisitTypeID


RETURN @blnValid
GO



 --------------------------------------------------------------------------------
 -- SP.3.6: Add NEW Patient
 --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspAddPatient
		 @intPatientID	AS INTEGER OUTPUT
		,@intSiteID		AS INTEGER
		,@dtmDOB		AS DATETIME
		,@intGenderID	AS INTEGER
		,@intWeight		AS INTEGER
AS
SET NOCOUNT ON;		--Report only errors
SET XACT_ABORT ON;	--Terminate and rollback entire transaction on error

DECLARE  @blnValid		AS BIT		= 0 -- false

-- Verify given patientID is valid
EXEC @blnValid = uspVerifyPatient @intPatientID

IF @blnValid > 0						-- true, patient exists
	PRINT 'Patient (' + CONVERT(VARCHAR(10), @intPatientID) + ') already exist. New Patient addition process for Patient (' + CONVERT(VARCHAR(10), @intPatientID) + ') was terminated.'
ELSE
	BEGIN
		-- Verify given siteID is valid
		EXEC @blnValid = uspVerifySite @intSiteID

		IF @blnValid = 0				-- false, site does not exist
			PRINT 'Site (' + CONVERT(VARCHAR(5), @intSiteID) + ') is invalid. New Patient addition process for Patient (' + CONVERT(VARCHAR(10), @intPatientID) + ') was terminated.'
		ELSE IF @blnValid > 0			-- true, valid site
			BEGIN 
				-- Yes, patient is unique (0) and site exists
				BEGIN TRANSACTION
					-- Get next patientID for site
					SELECT @intPatientID = COALESCE( ( MAX( intPatientID ) + 1 ), (@intSiteID * 1000 + 1) )
					FROM TPatients (TABLOCKX)
					WHERE intSiteID = @intSiteID;

					-- Insert new patient information
					INSERT INTO TPatients ( intPatientID, intSiteID, dtmDOB, intGenderID, intWeight )
					VALUES ( @intPatientID, @intSiteID, @dtmDOB, @intGenderID, @intWeight );

					-- Display result to user
					PRINT 'New Patient (' + CONVERT( VARCHAR, @intPatientID ) + ') was added successfully.';

				COMMIT TRANSACTION;
			END
	END
PRINT ' '
GO



 --------------------------------------------------------------------------------
 -- SP.3.7: Add NEW Patient Visit
 --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspAddPatientVisit
		 @intPatientID	AS INTEGER OUTPUT
		,@dtmVisit		AS DATETIME
		,@intVisitTypeID AS INTEGER
AS
SET NOCOUNT ON;		--Report only errors
SET XACT_ABORT ON;	--Terminate and rollback entire transaction on error

DECLARE  @blnValid		AS BIT		= 0 -- false
DECLARE	 @intVisitID	AS INTEGER 

-- Verify given patientID is valid
EXEC @blnValid = uspVerifyPatient @intPatientID

IF @blnValid > 0 -- true, patient exists
	BEGIN	 
		-- Verify given visittype is valid
		EXEC @blnValid = uspVerifyVisitType @intVisitTypeID

		IF @blnValid > 0 -- true, visit type exists
			BEGIN
				BEGIN TRANSACTION

					SELECT @intVisitID = COALESCE( ( MAX( intVisitID ) + 1 ), 1 )
					FROM TPatientVisits (TABLOCKX)

					INSERT INTO TPatientVisits ( intVisitID, intPatientID, dtmVisit, intVisitTypeID )
					VALUES ( @intVisitID, @intPatientID, @dtmVisit, @intVisitTypeID );

					PRINT 'New Patient Visit (' + CONVERT( VARCHAR, @intVisitID ) + ') for Patient (' + CONVERT( VARCHAR, @intPatientID ) + ') was added successfully.';

				COMMIT TRANSACTION;
			END
		ELSE
			PRINT 'Visit type (' + CONVERT(VARCHAR(10), @intVisitTypeID) + ') does not exist. New Patient Visit addition process for Patient (' + CONVERT(VARCHAR(10), @intPatientID) + ') was terminated.'
	END
ELSE IF @blnValid = 0					-- false, patient does not exist
	PRINT 'Patient (' + CONVERT(VARCHAR(10), @intPatientID) + ') does not exist. New Patient Visit addition process for Patient (' + CONVERT(VARCHAR(10), @intPatientID) + ') was terminated.'

PRINT ' '
GO



 --------------------------------------------------------------------------------
 -- SP.3.8: Delete random NON-randomized patient --> simulate real patients dropping out
 --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspDeleteANonRandPatient
		 @intStudyID		AS INTEGER
		,@intVisitTypeID	AS INTEGER
AS
SET NOCOUNT ON

DECLARE  @intPatientID		AS INTEGER = 0
DECLARE  @intRandom			AS INTEGER = 0

SELECT TOP (1)
	@intPatientID = intPatientID
FROM
	VAllPatientsNonRandNonWith
WHERE
	intStudyID = @intStudyID
AND intVisitTypeID = @intVisitTypeID
ORDER BY 
	NEWID();

SELECT @intRandom  = RAND() * 5 + 1 -- must be 1 - 6 --> 0*5+1 = 1, 1*5+1=6, 0.4*5+1=3

IF @intPatientID <> 0
	EXEC uspWithdrawPatient @intPatientID, @intRandom;

GO



 --------------------------------------------------------------------------------
 -- SP.3.9: Delete random randomized patient --> simulate real patients dropping out
 --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspDeleteARandPatient
		 @intStudyID		AS INTEGER
		,@intVisitTypeID	AS INTEGER
AS
SET NOCOUNT ON

DECLARE  @intPatientID		AS INTEGER = 0
DECLARE  @intRandom			AS INTEGER = 0

SELECT TOP (1)
	@intPatientID = intPatientID
FROM
	VAllPatientsRandNonWith
WHERE
	intStudyID = @intStudyID
AND intVisitTypeID = @intVisitTypeID
ORDER BY 
	NEWID();

SELECT @intRandom  = RAND() * 5 + 1 -- must be 1 - 6 --> 0*5+1 = 1, 1*5+1=6, 0.4*5+1=3

IF @intPatientID <> 0
	EXEC uspWithdrawPatient @intPatientID, @intRandom;

GO



-- --------------------------------------------------------------------------------
-- SP.3.10: Verify random code and/or drug kits remain
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspVerifyAvailableStudyCodes
		@intStudyID		AS INTEGER
AS
SET NOCOUNT ON;		--Report only errors

DECLARE  @blnValid		AS BIT		= 0

-- Verify random codes remain
SELECT	
	@blnValid = 1					-- true, codes remain available
FROM 
	VNextRandomCodeByStudy
WHERE
	intStudyID = @intStudyID

IF @blnValid = 1
	-- Yes, code remain
	BEGIN
		-- Reset flag
		SELECT @blnValid = 0

		-- Verify drug kits remain
		SELECT	
			@blnValid = 1					-- true, codes remain available
		FROM 
			VAllAvailableDrugKits	AS VAADK
				INNER JOIN TSites	AS TS
				ON VAADK.intSiteID = TS.intSiteID
		WHERE
			intStudyID = @intStudyID
		
		RETURN @blnValid -- 1 to continue, 0 to end study
	END
ELSE
	RETURN @blnValid
GO




-- --------------------------------------------------------------------------------
-- SP.3.11: Move Patient to next visit type
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspCompleteNextPatientVisit
		@intPatientID	AS INTEGER OUTPUT
AS
SET NOCOUNT ON

DECLARE @blnValid		As BIT = 0
DECLARE @intVisitID		AS INTEGER
DECLARE @dtmVisit		AS DATETIME = GETDATE()
DECLARE @intVisitTypeID AS INTEGER = 0
DECLARE @intRandom		AS INTEGER = 0 

-- Verify if a nex patient
EXEC @blnValid = uspVerifyPatient @intPatientID
IF @blnValid = 0
	BEGIN
		-- Yes. Does not exist, get patient info --> PatientID
		SELECT @intPatientID = 0
		EXEC uspAddPatient		@intPatientID OUTPUT, 501, '07/07/1999', 0, 130 ;
	END
ELSE
	-- No, reset flag
	SELECT @blnValid = 0

-- Verify last visit type
SELECT
	 @intVisitTypeID = intVisitTypeID
FROM
	VMostRecentPatientVisits
WHERE
	intPatientID = @intPatientID

IF @intVisitTypeID = 0		-- no previsou visits
	EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/08/2017', 1 
ELSE IF @intVisitTypeID = 1
	EXEC uspAddPatientVisit @intPatientID OUTPUT, @dtmVisit, 2 
ELSE IF	@intVisitTypeID = 2
	BEGIN
		SELECT
			@blnValid = 1
		FROM
			VAllPatientsRandNonWith
		WHERE 
			intPatientID = @intPatientID

		-- Does the patient have a random code
		IF @blnValid = 0
			-- No, Randomize patient
			EXEC uspPatientRandomization
		Else
			BEGIN
				-- Yes, patient has been randomized
				-- Get withdraw reason
				SELECT @intRandom  = RAND() * 5 + 1 -- must be 1 - 6 --> 0*5+1 = 1, 1*5+1=6, 0.4*5+1=3
				-- Withdraw patient
				EXEC uspWithdrawPatient @intPatientID, @intRandom
			END
	END
GO





-- --------------------------------------------------------------------------------
-- -----------------------------      SCRIPT END      -----------------------------
-- --------------------------------------------------------------------------------