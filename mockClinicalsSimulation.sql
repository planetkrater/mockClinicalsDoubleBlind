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
-- Script description: SIMULATE the patient admission and processing experience
--		Note: 'WARNING' message outputs to console when study runs out of materials.
--		Note: Views commented out are for QA purposes
-- --------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;							-- Get out of the master database
SET NOCOUNT ON;						-- Report only errors

-- Display Results
DECLARE @dteCurrent		AS DATE	= GETDATE()
DECLARE @blnValid		AS BIT = 0
DECLARE @intPatientID	AS INTEGER = 0;



-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- VIEW PROGRESS 1/5
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
--SELECT 'VIEW PROGRESS 1/5'
----SELECT intStudyID, intSiteID, intPatientID, intRandomCodeID, intVisitID, dteVisit, intVisitTypeID, intWithdrawReasonID 
----FROM VAllPatientVisits
--SELECT intStudyID, intSiteID, intPatientID, intRandomCodeID, intVisitID, dteVisit, intVisitTypeID, intWithdrawReasonID 
--FROM VMostRecentPatientVisits
--ORDER BY
--	intPatientID




-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- MATERIAL AVAILABILITY STATUS
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
EXEC @blnValid = uspVerifyAvailableStudyCodes 12345
IF @blnValid = 0
	BEGIN
		SELECT 'WARNING' AS  'WARNING: Available study materials (Random Codes and/or Drug Kits) have run out for Study (12345)'
		PRINT 'WARNING: Available study materials (Random Codes and/or Drug Kits) have run out for Study (12345)'
		PRINT ' '
	END
ELSE
	SELECT @blnValid = 0

EXEC @blnValid = uspVerifyAvailableStudyCodes 54321
IF @blnValid = 0
	BEGIN
		SELECT 'WARNING' AS 'WARNING: Available study materials (Random Codes and/or Drug Kits) have run out for Study (54321)'
		PRINT 'WARNING: Available study materials (Random Codes and/or Drug Kits) have run out for Study (54321)'
		PRINT ' '
	END
ELSE
	SELECT @blnValid = 0



-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- ADD NEW PATIENTS & ADD PATIENT VISITS & WITHDRAW NON-RANDOMIZED PATIENTS
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
--	STUDY 12345
-- --------------------------------------------------------------------------------
--  1
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 101, '07/07/1999', 0, 130 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/08/2017', 1 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, @dteCurrent, 2 ;
--  2
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 111, '07/17/1998', 1, 120 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/09/2017', 1 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, @dteCurrent, 2 ;
--  3
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 121, '07/27/1997', 2, 160 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '07/08/2017', 1 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, @dteCurrent, 2 ;

--  4
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 131, '07/30/1996', 1, 170 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '07/18/2017', 1 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, @dteCurrent, 2 ;
--  5
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 101, '07/07/1988', 0, 180 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '07/18/2017', 1 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, @dteCurrent, 2 ;
--  6
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 101, '07/17/1980', 1, 190 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/01/2017', 1 ;

--  7
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 111, '07/27/1987', 2, 100 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/02/2017', 1 ;

--  8
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 121, '07/30/1986', 1, 160 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/02/2017', 1 ;


-- --------------------------------------------------------------------------------
--	STUDY 54321
-- --------------------------------------------------------------------------------
--  1
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 501, '07/07/1979', 0, 130 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/05/2017', 1 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, @dteCurrent, 2 ;

--  2
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 511, '07/17/1978', 1, 120 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/10/2017', 1 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, @dteCurrent, 2 ;
--  3
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 521, '07/27/1977', 2, 160 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '07/30/2017', 1 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, @dteCurrent, 2 ;
--  4
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 531, '07/30/1976', 1, 170 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '07/28/2017', 1 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, @dteCurrent, 2 ;
-- 5
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 541, '07/09/1995', 2, 160 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/01/2017', 1 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, @dteCurrent, 2 ;

--  6
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 541, '07/08/1994', 1, 160 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/08/2017', 1 ;
--  7
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 511, '07/04/1993', 2, 160 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/08/2017', 1 ;
--  8
SELECT @intPatientID = 0
EXEC uspAddPatient		@intPatientID OUTPUT, 521, '07/07/1992', 1, 160 ;
EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/08/2017', 1 ;

--  9 EXTRA CREDIT
SELECT @intPatientID = 0
SELECT * FROM VMostRecentPatientVisits WHERE intPatientID = @intPatientID;
EXEC uspCompleteNextPatientVisit @intPatientID OUTPUT;
SELECT * FROM VMostRecentPatientVisits WHERE intPatientID = @intPatientID;
EXEC uspCompleteNextPatientVisit @intPatientID OUTPUT;
SELECT * FROM VMostRecentPatientVisits WHERE intPatientID = @intPatientID;
EXEC uspCompleteNextPatientVisit @intPatientID OUTPUT;
SELECT * FROM VMostRecentPatientVisits WHERE intPatientID = @intPatientID;
EXEC uspCompleteNextPatientVisit @intPatientID OUTPUT;
SELECT * FROM VMostRecentPatientVisits WHERE intPatientID = @intPatientID;



-- --------------------------------------------------------------------------------
--	ERROR TESTING
-- --------------------------------------------------------------------------------
-- 1
--SELECT @intPatientID = 0
--EXEC uspAddPatient @intPatientID OUTPUT, 000, '08/19/2017', 0, 100 ;
--EXEC uspAddPatientVisit @intPatientID OUTPUT, '08/08/2017', 1 ;
--EXEC uspWithdrawPatient @intPatientID, 6;
--EXEC uspWithdrawPatient 101001, 7;



-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- VIEW PROGRESS 2/5
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
--SELECT 'VIEW PROGRESS 2/5'
--SELECT intStudyID, intSiteID, intPatientID, intRandomCodeID, intVisitID, dteVisit, intVisitTypeID, intWithdrawReasonID 
--FROM VAllPatientVisits

--SELECT COUNT(DISTINCT intPatientID)
--FROM VAllPatientVisits
--WHERE intWithdrawReasonID IS NOT NULL



-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- WITHDRAW Two Random NON-RANDOMIZED PATIENTS - simulate patients dropping out
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
EXEC uspDeleteANonRandPatient 12345, 1;
EXEC uspDeleteANonRandPatient 12345, 2;
EXEC uspDeleteANonRandPatient 54321, 1;
EXEC uspDeleteANonRandPatient 54321, 2;



-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- VIEW PROGRESS 3/5
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
--SELECT 'VIEW PROGRESS 3/5 - Count existing Withdraw and RandomCodes'
--SELECT COUNT(DISTINCT intPatientID)
--FROM VAllPatientVisits
--WHERE intWithdrawReasonID IS NOT NULL

--SELECT COUNT(DISTINCT intPatientID)
--FROM VAllPatientVisits
--WHERE intRandomCodeID IS NOT NULL



-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- RANDOMIZE TODAY'S SCREENED PATIENTS
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
EXEC uspPatientRandomization;



-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- VIEW PROGRESS 4/5
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
--SELECT 'VIEW PROGRESS 4/5 - Count existing RandomCodes'
--SELECT COUNT(DISTINCT intPatientID)
--FROM VAllPatientsRandNonWith



-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- WITHDRAW RANDOMIZED PATIENTS
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
EXEC uspDeleteARandPatient 12345, 2;
EXEC uspDeleteARandPatient 12345, 2;
EXEC uspDeleteARandPatient 54321, 2;
EXEC uspDeleteARandPatient 54321, 2;


-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- VIEW PROGRESS 5/5
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
--SELECT 'VIEW PROGRESS 5/5 - Count existing RandomCodes'
----SELECT COUNT(DISTINCT intPatientID)
----FROM VAllPatientsRandNonWith
----SELECT intStudyID, intSiteID, intPatientID, intRandomCodeID, intVisitID, dteVisit, intVisitTypeID, intWithdrawReasonID 
----FROM VAllPatientVisits
--SELECT intStudyID, intSiteID, intPatientID, intRandomCodeID, intVisitID, dteVisit, intVisitTypeID, intWithdrawReasonID 
--FROM VMostRecentPatientVisits
--ORDER BY
--	intPatientID



-- --------------------------------------------------------------------------------
-- -----------------------------      SCRIPT END      -----------------------------
-- --------------------------------------------------------------------------------