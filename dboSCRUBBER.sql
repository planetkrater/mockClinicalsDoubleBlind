-- --------------------------------------------------------------------------------
-- Author: Kate Wamsley
-- Abstract: REMOVE ALL TABLES ETC from dbSQL1
-- --------------------------------------------------------------------------------



-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;							-- Get out of the master database
SET NOCOUNT ON;						-- Report only errors

-- --------------------------------------------------------------------------------
-- 0.0) Drop ALL Constraints, Tables, Views
-- --------------------------------------------------------------------------------
IF OBJECT_ID ('uspCheckTables')				IS NOT NULL DROP PROCEDURE uspCheckTables;
IF OBJECT_ID ('uspDropUserTables')			IS NOT NULL DROP PROCEDURE uspDropUserTables;
IF OBJECT_ID ('uspCheckViews')				IS NOT NULL DROP PROCEDURE uspCheckViews;
IF OBJECT_ID ('uspDropUserViews')			IS NOT NULL DROP PROCEDURE uspDropUserViews;
IF OBJECT_ID ('uspCheckForeignKeys')		IS NOT NULL DROP PROCEDURE uspCheckForeignKeys;
IF OBJECT_ID ('uspDropForeignKeys')			IS NOT NULL DROP PROCEDURE uspDropForeignKeys;
IF OBJECT_ID ('uspTCSandChangeLogCheck')	IS NOT NULL DROP PROCEDURE uspTCSandChangeLogCheck


-- --------------------------------------------------------------------------------
-- PROBLEM 3 - Drop Foreign keys, Views, Tables
-- --------------------------------------------------------------------------------
SELECT '' AS 'PROBLEM 3 - Drop Foreign keys, Views, Tables';
-- --------------------------------------------------------------------------------
-- 3.1) Using cursors, see example below, create a stored procedure named 
--		uspDropForeignKeys that will drop all foreign keys in the current database.  
--		After you create the stored procedure be sure to run/execute it to make 
--		sure it works.
-- --------------------------------------------------------------------------------
-- Procedure to LIST all ForeignKeys and child tables
GO
CREATE PROCEDURE uspCheckForeignKeys
AS
SET NOCOUNT ON
SET XACT_ABORT ON

SELECT
	 name						AS strForeignKey
	,OBJECT_NAME ( parent_obj )	AS strChildTable
FROM
	SysObjects
WHERE
	type = 'F'	--Foreign Keys only 
AND (
		name LIKE '%_FK'
		OR name LIKE '%_FK_'
	)
AND OBJECT_NAME ( parent_obj ) LIKE 'T%'
ORDER BY
	name
GO
-- --------------------------------------------------------------------------------


-- Procedure to DROP all ForeignKeys and child tables
GO
CREATE PROCEDURE uspDropForeignKeys
AS
SET NOCOUNT ON

DECLARE @strForeignKey			VARCHAR(250)
DECLARE @strChildTable			VARCHAR(250)
DECLARE @strTab					VARCHAR(250)
DECLARE @strMessage				VARCHAR(250)
DECLARE @strCommand				VARCHAR(250)
-- -- -- -- -- -- -- -- -- Drop all user foreign keys -- -- -- -- -- -- -- -- -- 
PRINT @strTab + 'DROP ALL USER FOREIGN KEYS ...'

DECLARE crsForeignKeys CURSOR FOR

  -- -- -- List of all ForeignKeys and corresponding child tables -- -- --
	SELECT
		 name						AS strForeignKey
		,OBJECT_NAME ( parent_obj )	AS strChildTable
	FROM
		SysObjects
	WHERE
		type = 'F'	--Foreign Keys only 
	AND (
			name LIKE '%_FK'
		 OR name LIKE '%_FK_'
		)
	AND OBJECT_NAME ( parent_obj ) LIKE 'T%'
	ORDER BY
		name

OPEN crsForeignKeys
FETCH NEXT FROM crsForeignKeys INTO @strForeignKey, @strChildTable

-- Loop until no more records
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Compile string
	SELECT @strMessage = @strTab + @strTab + '-DROP ' + @strForeignKey
	-- Print string
	PRINT @strMessage
	-- Build command
	SELECT @strCommand = 'ALTER TABLE ' + @strChildTable + ' DROP CONSTRAINT ' + @strForeignKey
	-- Execute command
	EXEC ( @strCommand )
	-- Get next list line
	FETCH NEXT FROM crsForeignKeys INTO @strForeignKey, @strChildTable
END

-- Clean up
CLOSE crsForeignKeys
DEALLOCATE crsForeignKeys

PRINT @strTab + 'DONE'
GO

-- BEFORE
SELECT 'All dbo Foreigns keys BEFORE' AS 'Problem 3.1';
EXEC uspCheckForeignKeys;
-- DROP Foreign Keys
EXEC uspDropForeignKeys;
-- AFTER
SELECT 'All dbo Foreigns keys AFTER' AS 'Problem 3.1';
EXEC uspCheckForeignKeys;

-- --------------------------------------------------------------------------------
-- 3.2) Using cursors, see example below, create a stored procedure named 
--		uspDropUserViews that will drop all user views in the current database.  
--		After you create the stored procedure be sure to run/execute it to make 
--		sure it works.
-- --------------------------------------------------------------------------------
-- Procedure to LIST all Views
GO
CREATE PROCEDURE uspCheckViews
AS
SET NOCOUNT ON
SET XACT_ABORT ON

SELECT
	 name						AS strView
FROM
	SysObjects
WHERE
	type = 'V'	--Views only 
ORDER BY
	name
GO
-- --------------------------------------------------------------------------------


-- Procedure to DROP all Views
GO
CREATE PROCEDURE uspDropUserViews
AS
SET NOCOUNT ON

DECLARE @strView				VARCHAR(250)
DECLARE @strTab					VARCHAR(250)
DECLARE @strMessage				VARCHAR(250)
DECLARE @strCommand				VARCHAR(250)
-- -- -- -- -- -- -- -- -- Drop all user views -- -- -- -- -- -- -- -- -- 
PRINT @strTab + 'DROP ALL USER VIEWS ...'

DECLARE crsViews CURSOR FOR

  -- -- -- List of all Views -- -- --
	SELECT
	 name						AS strView
	FROM
		SysObjects
	WHERE
		type = 'V'	--Views only 
	ORDER BY
		name

OPEN crsViews
FETCH NEXT FROM crsViews INTO @strView

-- Loop until no more records
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Compile string
	SELECT @strMessage = @strTab + @strTab + '-DROP ' + @strView
	-- Print string
	PRINT @strMessage
	-- Build command
	SELECT @strCommand = 'DROP VIEW dbo.' + @strView
	-- Execute command
	EXEC ( @strCommand )
	-- Get next list line
	FETCH NEXT FROM crsViews INTO @strView
END

-- Clean up
CLOSE crsViews
DEALLOCATE crsViews

PRINT @strTab + 'DONE'
GO

-- BEFORE
SELECT 'All dbo Views BEFORE'	AS 'Problem 3.2';
EXEC uspCheckViews;
-- DROP Views
EXEC uspDropUserViews;
-- AFTER
SELECT 'All dbo Views AFTER'	AS 'Problem 3.2';
EXEC uspCheckViews;



-- --------------------------------------------------------------------------------
-- 3.3) Using cursors, see example below, create a stored procedure named 
--		uspDropUserTables that will drop all user tables in the current database.  
--		After you create the stored procedure be sure to run/execute it to make 
--		sure it works.
-- --------------------------------------------------------------------------------
-- Procedure to LIST all Tables
GO
CREATE PROCEDURE uspCheckTables
AS
SET NOCOUNT ON
SET XACT_ABORT ON

SELECT
	 name						AS strTable
FROM
	SysObjects
WHERE
	type = 'U'	--Views only 
ORDER BY
	name
GO
-- --------------------------------------------------------------------------------


-- Procedure to DROP all Tables
GO
CREATE PROCEDURE uspDropUserTables
AS
SET NOCOUNT ON

DECLARE @strTable		VARCHAR(250)
DECLARE @strTab			VARCHAR(250)
DECLARE @strMessage		VARCHAR(250)
DECLARE @strCommand		VARCHAR(250)
-- -- -- -- -- -- -- -- -- Drop all user Tables -- -- -- -- -- -- -- -- -- 
PRINT @strTab + 'DROP ALL USER TABLES ...'

DECLARE crsTables CURSOR FOR

  -- -- -- List of all Tables -- -- --
	SELECT
	 name						AS strTable
	FROM
		SysObjects
	WHERE
		type = 'U'	--Views only 
	ORDER BY
		name

OPEN crsTables
FETCH NEXT FROM crsTables INTO @strTable

-- Loop until no more records
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Compile string
	SELECT @strMessage = @strTab + @strTab + '-DROP ' + @strTable
	-- Print string
	PRINT @strMessage
	-- Build command
	SELECT @strCommand = 'DROP TABLE dbo.' + @strTable
	-- Execute command
	EXEC ( @strCommand )
	-- Get next list line
	FETCH NEXT FROM crsTables INTO @strTable
END

-- Clean up
CLOSE crsTables
DEALLOCATE crsTables

PRINT @strTab + 'DONE'
GO

-- BEFORE
SELECT 'All dbo Tables BEFORE'	AS 'Problem 3.3';
EXEC uspCheckTables;
-- DROP Tables
EXEC uspDropUserTables;
-- AFTER
SELECT 'All dbo Tables AFTER'	AS 'Problem 3.3';
EXEC uspCheckTables;



-- --------------------------------------------------------------------------------
-- 3.4) Extra Credit #1
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 3.5) Extra Credit #2
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 3.6) I promise never, ever to create these stored procedures or anything 
--		like them on a production database unless my boss tells me to
--		Kate Wamsley
-- --------------------------------------------------------------------------------