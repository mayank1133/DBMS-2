-----------------------------Lab_5-----------------
-----Part_A-------------

-- Creating PersonInfo Table

CREATE TABLE PersonInfo (
 PersonID INT PRIMARY KEY,
 PersonName VARCHAR(100) NOT NULL,
 Salary DECIMAL(8,2) NOT NULL,
 JoiningDate DATETIME NULL,
 City VARCHAR(100) NOT NULL,
 Age INT NULL,
 BirthDate DATETIME NOT NULL
);

select * from PersonInfo

-- Creating PersonLog Table

CREATE TABLE PersonLog (
 PLogID INT PRIMARY KEY IDENTITY(1,1),
 PersonID INT NOT NULL,
 PersonName VARCHAR(250) NOT NULL,
 Operation VARCHAR(50) NOT NULL,
 UpdateDate DATETIME NOT NULL,
 FOREIGN KEY (PersonID) REFERENCES PersonInfo(PersonID) ON DELETE CASCADE
);

select * from PersonLog
---1. Create a trigger that fires on INSERT, UPDATE and DELETE operation on the PersonInfo table to display a message “Record is Affected.”

Create OR Alter Trigger tr_DisplayMesssage
on PersonInfo
After Insert,Update,Delete
as begin
	Print 'Record is Affected'
End


--2. Create a trigger that fires on INSERT, UPDATE and DELETE operation on the PersonInfo table. For that,log all operations performed on the person table into PersonLog
--Insert
Create OR Alter Trigger tr_LogOpt_Insert
on PersonInfo
After Insert
as begin
	Declare @PersonID int,@PersonName varchar(100)
	Select @PersonID=PersonID from inserted
	Select PersonName=@PersonName from inserted
	
	Insert into PersonLog (PersonID,PersonName,Operation,UpdateDate) values(@PersonID,@PersonName,'Inserted',GETDATE())
End

--Update
Create OR Alter Trigger tr_LogOpt_Update
on PersonInfo
After Update
as begin
	Declare @PersonID int,@PersonName varchar(100)
	Select @PersonID=PersonID from inserted
	Select PersonName=@PersonName from inserted
	
	Insert into PersonLog (PersonID,PersonName,Operation,UpdateDate) values(@PersonID,@PersonName,'Updated',GETDATE())
End

--Delete
Create OR Alter Trigger tr_LogOpt_Delete
on PersonInfo
After Delete
as begin
	Declare @PersonID int,@PersonName varchar(100)
	Select @PersonID=PersonID from deleted
	Select PersonName=PersonName from deleted
	
	Insert into PersonLog (PersonID,PersonName,Operation,UpdateDate) values(@PersonID,@PersonName,'Delete',GETDATE())
End

--3. Create an INSTEAD OF trigger that fires on INSERT, UPDATE and DELETE operation on the PersonInfo table. For that, log all operations performed on the person table into PersonLog.
--Insert
Create OR Alter Trigger TR_Log_Opt_Insert
on PersonInfo
Instead of Insert
as begin
	Declare @PersonID int,@PersonName varchar(100)
	Select @PersonID=@PersonID from inserted
	Select PersonName=@PersonName from inserted

	Insert into PersonLog (PersonID,PersonName,Operation,UpdateDate) values(@PersonID,@PersonName,'Inserted',GETDATE())
End

--Updated
Create OR Alter Trigger TR_Log_Opt_Update
on PersonInfo
Instead of Update
as begin
	Declare @PersonID int,@PersonName varchar(100)
	Select @PersonID=@PersonID from inserted
	Select PersonName=@PersonName from inserted

	Insert into PersonLog (PersonID,PersonName,Operation,UpdateDate) values(@PersonID,@PersonName,'Update',GETDATE())
End

--Deleted
Create OR Alter Trigger TR_Log_Opt_Delete
on PersonInfo
Instead of Delete
as begin
	Declare @PersonID int,@PersonName varchar(100)
	Select @PersonID=@PersonID from deleted
	Select PersonName=@PersonName from deleted

	Insert into PersonLog (PersonID,PersonName,Operation,UpdateDate) values(@PersonID,@PersonName,'Delete',GETDATE())
End

--4.Create a trigger that fires on INSERT operation on the PersonInfo table to convert person name into uppercase whenever the record is inserted.
Create OR Alter TRIGGER tr_UppercaseName
ON PersonInfo
AFTER INSERT
AS
BEGIN
    UPDATE PersonInfo
    SET PersonName = UPPER(PersonName)
    WHERE PersonID IN (SELECT PersonID FROM inserted);
END;
