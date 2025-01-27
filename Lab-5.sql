-- PART 1: CREATE THE TABLES
-- TABLE FOR PERSONINFO
CREATE TABLE PERSON_INFO (
    PERSONID INT PRIMARY KEY,
    PERSONNAME VARCHAR(100) NOT NULL,
    SALARY DECIMAL(8, 2) NOT NULL,
    JOININGDATE DATETIME NULL,
    CITY VARCHAR(100) NOT NULL,
    AGE INT NULL,
    BIRTHDATE DATETIME NOT NULL
);

-- TABLE FOR PERSONLOG
CREATE TABLE PERSONLOG (
    PLOGID INT IDENTITY(1,1) PRIMARY KEY,  
    PERSONID INT NOT NULL,
    PERSONNAME VARCHAR(250) NOT NULL,
    OPERATION VARCHAR(50) NOT NULL,
    UPDATEDATE DATETIME NOT NULL,
    FOREIGN KEY (PERSONID) REFERENCES PERSONINFO(PERSONID)  
);


-- PART 2: TRIGGERS

-- 1. TRIGGER TO DISPLAY A MESSAGE WHEN A RECORD IS AFFECTED (INSERT, UPDATE, DELETE)

CREATE OR ALTER TRIGGER RECORDAFFECTEDTRIGGER
ON PERSONINFO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'RECORD IS AFFECTED.';
END;

-- 2. TRIGGER TO LOG OPERATIONS ON PERSONINFO INTO PERSONLOG

CREATE OR ALTER TRIGGER LOGPERSONINFOCHANGES
ON PERSONINFO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @OPERATION VARCHAR(50), @PERSONID INT, @PERSONNAME VARCHAR(250), @UPDATEDATE DATETIME;

    IF EXISTS (SELECT * FROM INSERTED)
    BEGIN
        SET @OPERATION = 'INSERT';
        SELECT @PERSONID = PERSONID, @PERSONNAME = PERSONNAME FROM INSERTED;
    END
    ELSE IF EXISTS (SELECT * FROM DELETED)
    BEGIN
        SET @OPERATION = 'DELETE';
        SELECT @PERSONID = PERSONID, @PERSONNAME = PERSONNAME FROM DELETED;
    END

    SET @UPDATEDATE = GETDATE();

    INSERT INTO PERSONLOG (PERSONID, PERSONNAME, OPERATION, UPDATEDATE)
    VALUES (@PERSONID, @PERSONNAME, @OPERATION, @UPDATEDATE);
END;

-- 3. INSTEAD OF TRIGGER TO LOG OPERATIONS AND PERFORM INSERT, DELETE ON PERSONINFO

CREATE OR ALTER TRIGGER INSTEADOFLOGPERSONINFOCHANGES
ON PERSONINFO
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @OPERATION VARCHAR(50), @PERSONID INT, @PERSONNAME VARCHAR(250), @UPDATEDATE DATETIME;

    IF EXISTS (SELECT * FROM INSERTED)
    BEGIN
        SET @OPERATION = 'INSERT';
        SELECT @PERSONID = PERSONID, @PERSONNAME = PERSONNAME FROM INSERTED;
        INSERT INTO PERSONINFO (PERSONID, PERSONNAME, SALARY, JOININGDATE, CITY, AGE, BIRTHDATE)
        SELECT PERSONID, PERSONNAME, SALARY, JOININGDATE, CITY, AGE, BIRTHDATE FROM INSERTED;
    END
    ELSE IF EXISTS (SELECT * FROM DELETED)
    BEGIN
        SET @OPERATION = 'DELETE';
        SELECT @PERSONID = PERSONID, @PERSONNAME = PERSONNAME FROM DELETED;
        DELETE FROM PERSONINFO WHERE PERSONID = @PERSONID;
    END

    SET @UPDATEDATE = GETDATE();
    INSERT INTO PERSONLOG (PERSONID, PERSONNAME, OPERATION, UPDATEDATE)
    VALUES (@PERSONID, @PERSONNAME, @OPERATION, @UPDATEDATE);
END;
DROP TRIGGER RECORDAFFECTEDTRIGGER,LOGPERSONINFOCHANGES,INSTEADOFLOGPERSONINFOCHANGES

-- 4. TRIGGER TO CONVERT PERSON NAME INTO UPPERCASE WHEN INSERTING A RECORD

CREATE OR ALTER TRIGGER CONVERTNAMETOUPPER
ON PERSONINFO
AFTER INSERT
AS
BEGIN
    UPDATE PERSONINFO
    SET PERSONNAME = UPPER(PERSONNAME)
    WHERE PERSONID IN (SELECT PERSONID FROM INSERTED);
END;

-- 5. TRIGGER TO PREVENT DUPLICATE ENTRIES OF PERSON NAME

CREATE OR ALTER TRIGGER PREVENTDUPLICATENAME
ON PERSONINFO
BEFORE INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM PERSONINFO WHERE PERSONNAME = (SELECT PERSONNAME FROM INSERTED))
    BEGIN
        PRINT 'DUPLICATE ENTRY FOR PERSON NAME IS NOT ALLOWED.';
        ROLLBACK TRANSACTION;
    END;
END;

-- 6. TRIGGER TO PREVENT AGE BELOW 18 YEARS

CREATE TRIGGER PREVENTAGEBELOW18
ON PERSONINFO
BEFORE INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM INSERTED WHERE AGE < 18)
    BEGIN
        PRINT 'AGE CANNOT BE LESS THAN 18.';
        ROLLBACK TRANSACTION;
    END;
END;

-- PART B: MORE TRIGGERS


-- 7. TRIGGER TO CALCULATE AGE AND UPDATE IT WHEN INSERTING INTO PERSONINFO

CREATE TRIGGER CALCULATEAGE
ON PERSONINFO
AFTER INSERT
AS
BEGIN
    DECLARE @BIRTHDATE DATETIME, @AGE INT;

    SELECT @BIRTHDATE = BIRTHDATE FROM INSERTED;

    SET @AGE = DATEDIFF(YEAR, @BIRTHDATE, GETDATE());

    UPDATE PERSONINFO
    SET AGE = @AGE
    WHERE PERSONID IN (SELECT PERSONID FROM INSERTED);
END;


-- 8. TRIGGER TO LIMIT SALARY DECREASE BY 10%

CREATE TRIGGER LIMITSALARYDECREASE
ON PERSONINFO
AFTER UPDATE
AS
BEGIN
    DECLARE @OLDSALARY DECIMAL(8,2), @NEWSALARY DECIMAL(8,2);

    SELECT @OLDSALARY = SALARY FROM DELETED;
    SELECT @NEWSALARY = SALARY FROM INSERTED;

    IF @NEWSALARY < @OLDSALARY * 0.9
    BEGIN
        PRINT 'SALARY DECREASE EXCEEDS 10%.';
        ROLLBACK TRANSACTION;
    END;
END;


-- PART C: FURTHER TRIGGERS

-- 9. TRIGGER TO UPDATE JOININGDATE TO CURRENT DATE IF IT IS NULL DURING INSERT

CREATE OR ALTER TRIGGER SETJOININGDATE
ON PERSONINFO
AFTER INSERT
AS
BEGIN
    UPDATE PERSONINFO
    SET JOININGDATE = ISNULL(JOININGDATE, GETDATE())
    WHERE PERSONID IN (SELECT PERSONID FROM INSERTED);
END;

-- 10. TRIGGER TO PRINT A MESSAGE WHEN A RECORD IS DELETED FROM PERSONLOG


CREATE OR ALTER TRIGGER DELETEPERSONLOGRECORD
ON PERSONLOG
AFTER DELETE
AS
BEGIN
    PRINT 'RECORD DELETED SUCCESSFULLY FROM PERSONLOG';
END;



-- EXTRA LAB --
CREATE TABLE EMPLOYEE_DETAILS
(
	EmployeeID Int Primary Key,
	EmployeeName Varchar(100) Not Null,
	ContactNo Varchar(100) Not Null,
	Department Varchar(100) Not Null,
	Salary Decimal(10,2) Not Null,
	JoiningDate DateTime Null
)

CREATE TABLE EmployeeLogs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT NOT NULL,
    EmployeeName VARCHAR(100) NOT NULL,
    ActionPerformed VARCHAR(100) NOT NULL,
    ActionDate DATETIME NOT NULL
);


-- 1)	Create a trigger that fires AFTER INSERT, UPDATE, and DELETE operations on the EmployeeDetails table to display the message "Employee record inserted", "Employee record updated", "Employee record deleted"

CREATE  TRIGGER Employee_Details_1
ON EMPLOYEE_DETAILS
AFTER INSERT
AS
BEGIN
    PRINT 'RECORD IS INSERTED.';
END;

CREATE  TRIGGER Employee_Details_2
ON EMPLOYEE_DETAILS
AFTER UPDATE
AS
BEGIN
    PRINT 'RECORD IS UPDATED.';
END;

CREATE  TRIGGER Employee_Details_3
ON EMPLOYEE_DETAILS
AFTER DELETE
AS
BEGIN
    PRINT 'RECORD IS DELETED.';
END;

-- 2)	Create a trigger that fires AFTER INSERT, UPDATE, and DELETE operations on the EmployeeDetails table to log all operations into the EmployeeLog table.

CREATE TRIGGER LogEmployeeDetails
ON Employee_Details
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Action VARCHAR(100);
    DECLARE @EmployeeID INT;
    DECLARE @EmployeeName VARCHAR(100);
    
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Action = 'INSERT';
        SELECT @EmployeeID = EmployeeID, @EmployeeName = EmployeeName FROM inserted;
    END

    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Action = 'DELETE';
        SELECT @EmployeeID = EmployeeID, @EmployeeName = EmployeeName FROM deleted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Action = 'UPDATE';
        SELECT @EmployeeID = EmployeeID, @EmployeeName = EmployeeName FROM inserted;
    END

    INSERT INTO EmployeeLogs (EmployeeID, EmployeeName, ActionPerformed, ActionDate)
    VALUES (@EmployeeID, @EmployeeName, @Action, GETDATE());
END;

-- 3)	Create a trigger that fires AFTER INSERT to automatically calculate the joining bonus (10% of the salary) for new employees and update a bonus column in the EmployeeDetails table.

CREATE TRIGGER CalculateJoiningBonus
ON Employee_Details
AFTER INSERT
AS
BEGIN
    DECLARE @Salary DECIMAL(10, 2);
    DECLARE @Bonus DECIMAL(10, 2);
    
    SELECT @Salary = Salary FROM inserted;

    SET @Salary = @Salary * 0.10;

    UPDATE EMPLOYEE_DETAILS
    SET Salary = @Salary
    WHERE EmployeeID IN (SELECT EmployeeID FROM inserted);
END;

-- 4)	Create a trigger to ensure that the JoiningDate is automatically set to the current date if it is NULL during an INSERT operation.

CREATE TRIGGER SetJoiningDateIfNull
ON Employee_Details
AFTER INSERT
AS
BEGIN
    UPDATE Employee_Details
    SET JoiningDate = ISNULL(JoiningDate, GETDATE())
    WHERE EmployeeID IN (SELECT EmployeeID FROM inserted);
END;

-- 5)	Create a trigger that ensure that ContactNo is valid during insert and update (Like ContactNo length is 10)

CREATE TRIGGER Validate__ContactNo
ON Employee_Details
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @EMPLOYEEID INT 
	SELECT @EMPLOYEEID = @EMPLOYEEID
    IF EXISTS (SELECT * FROM inserted WHERE LEN(ContactNo) != 10)
    BEGIN
       DELETE FROM EMPLOYEE_DETAILS
	   WHERE EMPLOYEEID = @EMPLOYEEID
    END
END;


CREATE TABLE Movies (
    MovieID INT PRIMARY KEY,
    MovieTitle VARCHAR(255) NOT NULL,
    ReleaseYear INT NOT NULL,
    Genre VARCHAR(100) NOT NULL,
    Rating DECIMAL(3, 1) NOT NULL,
    Duration INT NOT NULL
);




-- 1.	Create an INSTEAD OF trigger that fires on INSERT, UPDATE and DELETE operation on the Movies table. For that, log all operations performed on the Movies table into MoviesLog.

CREATE TRIGGER LogMoviesOperations
ON Movies
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO MoviesLog (MovieID, MovieTitle, ActionPerformed, ActionDate)
        SELECT MovieID, MovieTitle, 'INSERT', GETDATE()
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO MoviesLog (MovieID, MovieTitle, ActionPerformed, ActionDate)
        SELECT MovieID, MovieTitle, 'UPDATE', GETDATE()
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO MoviesLog (MovieID, MovieTitle, ActionPerformed, ActionDate)
        SELECT MovieID, MovieTitle, 'DELETE', GETDATE()
        FROM deleted;
    END
END;	
DROP TRIGGER LogMoviesOperations
-- 2.	Create a trigger that only allows to insert movies for which Rating is greater than 5.5 .
CREATE TRIGGER ValidateMovie
ON Movies
INSTEAD OF INSERT,UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE Rating >= 5.5)
    BEGIN
		 INSERT INTO Movies (MovieID, MovieTitle, ReleaseYear, Genre, Rating, Duration)
        SELECT MovieID, MovieTitle, ReleaseYear, Genre, Rating, Duration FROM inserted;
    END
END;
DROP TRIGGER ValidateMovie

-- 3.	Create trigger that prevent duplicate 'MovieTitle' of Movies table and log details of it in MoviesLog table.

CREATE TRIGGER PreventDuplicateMovieTitle
ON Movies
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted i INNER JOIN Movies m ON i.MovieTitle = m.MovieTitle)
    BEGIN
        DECLARE @MovieID INT;
        DECLARE @MovieTitle VARCHAR(255);
        SELECT @MovieID = MovieID, @MovieTitle = MovieTitle FROM inserted;
        
        INSERT INTO MoviesLog (MovieID, MovieTitle, ActionPerformed, ActionDate)
        VALUES (@MovieID, @MovieTitle, 'Duplicate Insert Attempt', GETDATE());
        
        RAISERROR('MovieTitle already exists in the database.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Movies (MovieID, MovieTitle, ReleaseYear, Genre, Rating, Duration)
        SELECT MovieID, MovieTitle, ReleaseYear, Genre, Rating, Duration FROM inserted;
    END
END;
DROP TRIGGER PreventDuplicateMovieTitle
-- 4.	Create trigger that prevents to insert pre-release movies.
CREATE TRIGGER PreventPreReleaseMovies
ON Movies
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE ReleaseYear > YEAR(GETDATE()))
    BEGIN
        INSERT INTO Movies (MovieID, MovieTitle, ReleaseYear, Genre, Rating, Duration)
        SELECT MovieID, MovieTitle, ReleaseYear, Genre, Rating, Duration FROM inserted;
    END
END;
DROP TRIGGER PreventPreReleaseMovies

-- 5.	Develop a trigger to ensure that the Duration of a movie cannot be updated to a value greater than 120 minutes (2 hours) to prevent unrealistic entries.
















 

    CREATE TRIGGER LogMoviesOperations
ON Movies
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    -- Log Insert operations
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO MoviesLog (MovieID, MovieTitle, ActionPerformed, ActionDate)
        SELECT MovieID, MovieTitle, 'INSERT', GETDATE()
        FROM inserted;
    END

    -- Log Update operations
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO MoviesLog (MovieID, MovieTitle, ActionPerformed, ActionDate)
        SELECT MovieID, MovieTitle, 'UPDATE', GETDATE()
        FROM inserted;
    END

    -- Log Delete operations
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO MoviesLog (MovieID, MovieTitle, ActionPerformed, ActionDate)
        SELECT MovieID, MovieTitle, 'DELETE', GETDATE()
        FROM deleted;
    END
END;
