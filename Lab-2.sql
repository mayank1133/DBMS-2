--LAB-2--
-- Create Department Table
CREATE TABLE Department (
 DepartmentID INT PRIMARY KEY,
 DepartmentName VARCHAR(100) NOT NULL UNIQUE
);
-- Create Designation Table
CREATE TABLE Designation (
 DesignationID INT PRIMARY KEY,
 DesignationName VARCHAR(100) NOT NULL UNIQUE
);
-- Create Person Table
CREATE TABLE Person (
 PersonID INT PRIMARY KEY IDENTITY(101,1),
 FirstName VARCHAR(100) NOT NULL,
 LastName VARCHAR(100) NOT NULL,
 Salary DECIMAL(8, 2) NOT NULL,
 JoiningDate DATETIME NOT NULL,
 DepartmentID INT NULL,
 DesignationID INT NULL,
 FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
 FOREIGN KEY (DesignationID) REFERENCES Designation(DesignationID)
);

--PROCEDURE--

--DEPARTMENT--

--INSERT--

CREATE or ALTER PROCEDURE PR_Department_Insert
	@DepartmentID INT,
	@DepartmentName VARCHAR(100)
AS
BEGIN
	INSERT INTO Department
	VALUES
		(
			@DepartmentID,
			@DepartmentName
		)
END

EXEC PR_Department_Insert 4,'Account'

--UPDATE--

CREATE or ALTER PROCEDURE PR_Department_Update
	@DepartmentID INT,
	@DepartmentName VARCHAR(100)
AS
BEGIN
	UPDATE Department
	SET DepartmentName=@DepartmentName
	WHERE DepartmentID = @DepartmentID
END

EXEC PR_Department_Update 1,'ADMIN'

--DELETE--

CREATE or ALTER PROCEDURE PR_Department_Delete
	@DepartmentID INT
AS
BEGIN
	DELETE FROM Department
	WHERE DepartmentID = @DepartmentID

END

--DESIGNATION--

--INSERT--

CREATE or ALTER PROCEDURE PR_Designation_Insert
	@DesignationID INT,
	@DesignationName VARCHAR(100)
AS
BEGIN
	INSERT INTO Department
	VALUES
		(
			@DesignationID,
			@DesignationName
		)
END

EXEC PR_Designation_Insert 15,'CEO'

--UPDATE--

CREATE or ALTER PROCEDURE PR_Designation_Update
	@DesignationID INT,
	@DesignationName VARCHAR(100)
AS
BEGIN
	UPDATE Designation
	SET DesignationName = @DesignationName
	WHERE DesignationID = @DesignationID
END

-- DELETE --

CREATE or ALTER PROCEDURE PR_Designation_Update
	@DesignationID INT
AS
BEGIN
	DELETE FROM Designation
	WHERE DesignationID = @DesignationID
END

-- PERSON -- 

-- INSERT --

CREATE or ALTER PROCEDURE PR_Person_Insert
	@PersonID INT,
	@FirstName VARCHAR (100),
	@LastName VARCHAR (100),
	@Salary DECIMAL(8,2),
	@JoiningDate DATETIME,
	@DepartmentID INT,
	@DesignationID INT
AS
BEGIN
	INSERT INTO Person
	(
		PersonID, 
		FirstName, 
		LastName, 
		Salary, 
		JoiningDate, 
		DepartmentID, 
		DesignationID
	)
	VALUES
	(
		PersonID = @PersonID,
		FirstName = @FirstName, 
		LastName = @LastName,
		Salary = @Salary, 
		JoiningDate = @JoiningDate, 
		DepartmentID = @DepartmentID, 
		DesignationID = @DesignationID
	)

END


-- 2. Department, Designation & Person Table’s SELECTBYPRIMARYKEY
--- ============================================
--- ============================================

-- Procedure for selecting Department by Primary Key (DepartmentID)
CREATE PROCEDURE SelectDepartmentByPrimaryKey 
    @p_DepartmentID INT
AS
BEGIN
    -- Question: Select details of a Department based on DepartmentID (Primary Key)
    SELECT DepartmentID, DepartmentName
    FROM Department
    WHERE DepartmentID = @p_DepartmentID;
END;


-- Procedure for selecting Designation by Primary Key (DesignationID)
CREATE PROCEDURE SelectDesignationByPrimaryKey 
    @p_DesignationID INT
AS
BEGIN
    -- Question: Select details of a Designation based on DesignationID (Primary Key)
    SELECT DesignationID, DesignationName
    FROM Designation
    WHERE DesignationID = @p_DesignationID;
END;


-- Procedure for selecting Person by Primary Key (PersonID)
CREATE PROCEDURE SelectPersonByPrimaryKey 
    @p_PersonID INT
AS
BEGIN
    -- Question: Select details of a Person based on PersonID (Primary Key)
    SELECT PersonID, FirstName, LastName, Salary, JoiningDate, DepartmentID, DesignationID
    FROM Person
    WHERE PersonID = @p_PersonID;
END;


-- ============================================
-- 3. Department, Designation & Person Table’s (If foreign key is available then do write join and take columns on select list)
-- ============================================

-- Procedure for selecting Person with Department and Designation details using JOINs
CREATE PROCEDURE SelectPersonWithDepartmentAndDesignation 
    @p_PersonID INT
AS
BEGIN
    -- Question: If foreign key is available (DepartmentID and DesignationID), join the tables to fetch details
    SELECT 
        p.PersonID, 
        p.FirstName, 
        p.LastName, 
        p.Salary, 
        p.JoiningDate, 
        d.DepartmentName, 
        de.DesignationName
    FROM Person p
    LEFT JOIN Department d ON p.DepartmentID = d.DepartmentID
    LEFT JOIN Designation de ON p.DesignationID = de.DesignationID
    WHERE p.PersonID = @p_PersonID;
END;


-- ============================================
-- 4. Create a Procedure that shows details of the first 3 persons
-- ============================================

-- Procedure for selecting the first 3 persons along with their Department and Designation details
CREATE PROCEDURE SelectFirstThreePersons 
AS
BEGIN
    -- Question: Show details of the first 3 persons based on PersonID (including Department and Designation details)
    SELECT 
        p.PersonID, 
        p.FirstName, 
        p.LastName, 
        p.Salary, 
        p.JoiningDate, 
        d.DepartmentName, 
        de.DesignationName
    FROM Person p
    LEFT JOIN Department d ON p.DepartmentID = d.DepartmentID
    LEFT JOIN Designation de ON p.DesignationID = de.DesignationID
    ORDER BY p.PersonID
    
END

