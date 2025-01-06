
use CSE_A5_194
-- Create the Products table
CREATE TABLE Products (
 Product_id INT PRIMARY KEY,
 Product_Name VARCHAR(250) NOT NULL,
 Price DECIMAL(10, 2) NOT NULL
);
-- Insert data into the Products table
INSERT INTO Products (Product_id, Product_Name, Price) VALUES
(1, 'Smartphone', 35000),
(2, 'Laptop', 65000),
(3, 'Headphones', 5500),
(4, 'Television', 85000),
(5, 'Gaming Console', 32000);
select * from Products


-- Part - A --
-- 1. Create a cursor Product_Cursor to fetch all the rows from a products table.

DECLARE Product_Cursorr CURSOR FOR
SELECT Product_id, Product_Name, Price FROM Products;

DECLARE @ProductId INT, @ProductName VARCHAR(250), @Price DECIMAL(10, 2);

OPEN Product_Cursorr;

FETCH NEXT FROM Product_Cursorr INTO @ProductId, @ProductName, @Price;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Product ID: ' + CAST(@ProductId AS VARCHAR) + ', Product Name: ' + @ProductName + ', Price: ' + CAST(@Price AS VARCHAR);
    
    FETCH NEXT FROM Product_Cursorr INTO @ProductId, @ProductName, @Price;
END;

CLOSE Product_Cursorr;

DEALLOCATE Product_Cursorr;

--2. Create a cursor Product_Cursor_Fetch to fetch the records in form of ProductID_ProductName.
--(Example: 1_Smartphone)

DECLARE Product_Cursor_Fetch CURSOR FOR
SELECT CONCAT(Product_id, '_', Product_Name) AS ProductID_ProductName FROM Products;

DECLARE @ProductID_ProductName VARCHAR(255);

OPEN Product_Cursor_Fetch;

FETCH NEXT FROM Product_Cursor_Fetch INTO @ProductID_ProductName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @ProductID_ProductName;
    
    FETCH NEXT FROM Product_Cursor_Fetch INTO @ProductID_ProductName;
END;

CLOSE Product_Cursor_Fetch;

DEALLOCATE Product_Cursor_Fetch;

--3. Create a Cursor to Find and Display Products Above Price 30,000.
DECLARE Product_Cursor_Above30k CURSOR FOR
SELECT Product_id, Product_Name, Price FROM Products WHERE Price > 30000;

DECLARE @ProductId INT, @ProductName VARCHAR(250), @Price DECIMAL(10, 2);

OPEN Product_Cursor_Above30k;

FETCH NEXT FROM Product_Cursor_Above30k INTO @ProductId, @ProductName, @Price;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Product ID: ' + CAST(@ProductId AS VARCHAR) + ', Product Name: ' + @ProductName + ', Price: ' + CAST(@Price AS VARCHAR);
    
    FETCH NEXT FROM Product_Cursor_Above30k INTO @ProductId, @ProductName, @Price;
END;

CLOSE Product_Cursor_Above30k;

DEALLOCATE Product_Cursor_Above30k;

-- 4. Create a cursor Product_CursorDelete that deletes all the data from the Products table.DECLARE Product_CursorDelete CURSOR FOR
SELECT Product_id FROM Products;

DECLARE @ProductId INT;

OPEN Product_CursorDelete;

FETCH NEXT FROM Product_CursorDelete INTO @ProductId;

WHILE @@FETCH_STATUS = 0
BEGIN
    DELETE FROM Products WHERE Product_id = @ProductId;

    FETCH NEXT FROM Product_CursorDelete INTO @ProductId;
END;

CLOSE Product_CursorDelete;

DEALLOCATE Product_CursorDelete;

-- PART-B--

-- 5. Create a cursor Product_CursorUpdate that retrieves all the data from the products table and increases
-- the price by 10%.

DECLARE Product_CursorUpdate CURSOR FOR
SELECT Product_id, Price FROM Products;

DECLARE @ProductId INT, @Price DECIMAL(10, 2);

OPEN Product_CursorUpdate;

FETCH NEXT FROM Product_CursorUpdate INTO @ProductId, @Price;

WHILE @@FETCH_STATUS = 0
BEGIN

    UPDATE Products
    SET Price = @Price * 1.10
    WHERE Product_id = @ProductId;

    FETCH NEXT FROM Product_CursorUpdate INTO @ProductId, @Price;
END;

CLOSE Product_CursorUpdate;

DEALLOCATE Product_CursorUpdate;

SELECT * FROM Products

--6. Create a Cursor to Rounds the price of each product to the nearest whole number.

DECLARE Product_CursorRound CURSOR FOR
SELECT Product_id, Price FROM Products;

DECLARE @ProductId INT, @Price DECIMAL(10, 2);

OPEN Product_CursorRound;

FETCH NEXT FROM Product_CursorRound INTO @ProductId, @Price;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE Products
    SET Price = ROUND(@Price, 0) 
    WHERE Product_id = @ProductId;

    FETCH NEXT FROM Product_CursorRound INTO @ProductId, @Price;
END;

CLOSE Product_CursorRound;

DEALLOCATE Product_CursorRound;












-- PART-C --

-- 7. Create a cursor to insert details of Products into the NewProducts table if the product is “Laptop”
-- (Note: Create NewProducts table first with same fields as Products table)

CREATE TABLE NewProducts (
    Product_id INT PRIMARY KEY,
    Product_Name VARCHAR(250) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);

DECLARE Product_CursorInsertLaptop CURSOR FOR
SELECT Product_id, Product_Name, Price FROM Products WHERE Product_Name = 'Laptop';

DECLARE @ProductId INT, @ProductName VARCHAR(250), @Price DECIMAL(10, 2);

OPEN Product_CursorInsertLaptop;

FETCH NEXT FROM Product_CursorInsertLaptop INTO @ProductId, @ProductName, @Price;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO NewProducts (Product_id, Product_Name, Price)
    VALUES (@ProductId, @ProductName, @Price);

    FETCH NEXT FROM Product_CursorInsertLaptop INTO @ProductId, @ProductName, @Price;
END;

CLOSE Product_CursorInsertLaptop;

DEALLOCATE Product_CursorInsertLaptop;


-- 8. Create a Cursor to Archive High-Price Products in a New Table (ArchivedProducts), Moves products
-- with a price above 50000 to an archive table, removing them from the original Products table.
CREATE TABLE ArchivedProducts (
    Product_id INT PRIMARY KEY,
    Product_Name VARCHAR(250) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);
DECLARE Product_CursorArchive CURSOR FOR
SELECT Product_id, Product_Name, Price FROM Products WHERE Price > 50000;

DECLARE @ProductId INT, @ProductName VARCHAR(250), @Price DECIMAL(10, 2);

OPEN Product_CursorArchive;

FETCH NEXT FROM Product_CursorArchive INTO @ProductId, @ProductName, @Price;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO ArchivedProducts (Product_id, Product_Name, Price)
    VALUES (@ProductId, @ProductName, @Price);

    DELETE FROM Products WHERE Product_id = @ProductId;

    FETCH NEXT FROM Product_CursorArchive INTO @ProductId, @ProductName, @Price;
END;

CLOSE Product_CursorArchive;

DEALLOCATE Product_CursorArchive;

