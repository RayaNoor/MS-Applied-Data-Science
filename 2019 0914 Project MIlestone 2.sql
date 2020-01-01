/*
	Author	: Raya Young
	Course	: IST659 M404
	Term	: July, 2019
*/

-- drop all constraints in reverse order of their dependencies.
IF OBJECT_ID('dbo.Transaction', 'U') IS NOT NULL
	ALTER TABLE "Transaction"
	DROP CONSTRAINT FK3_Transaction,
		 CONSTRAINT FK2_Transaction,
		 CONSTRAINT FK1_Transaction
GO

IF OBJECT_ID('dbo.Bird', 'U') IS NOT NULL
	ALTER TABLE Bird
	DROP CONSTRAINT FK2_Bird,
		 CONSTRAINT FK1_Bird
GO

-- drop all tables in reverse order of their dependencies.
IF OBJECT_ID('dbo.Transaction', 'U') IS NOT NULL
	DROP TABLE "Transaction"
GO

IF OBJECT_ID('dbo.Mating_Pair', 'U') IS NOT NULL
	DROP TABLE Mating_Pair
GO

IF OBJECT_ID('dbo.Bird', 'U') IS NOT NULL
	DROP TABLE Bird
GO

IF OBJECT_ID('dbo.Wild', 'U') IS NOT NULL
	DROP TABLE Wild
GO

IF OBJECT_ID('dbo.Zoo', 'U') IS NOT NULL
	DROP TABLE Zoo
GO

-- drop all procedures, views, functions...
IF OBJECT_ID('BuySell', 'P') IS NOT NULL
	DROP PROCEDURE dbo.BuySell;
GO

IF OBJECT_ID('WildRelease', 'P') IS NOT NULL
	DROP PROCEDURE dbo.WildRelease;
GO

IF OBJECT_ID('ChicksPerPair', 'V') IS NOT NULL
	DROP VIEW dbo.ChicksPerPair;
GO

IF OBJECT_ID('MostProlificPair', 'V') IS NOT NULL
	DROP VIEW dbo.MostProlificPair;
GO

IF OBJECT_ID('AvgOPerZoo', 'V') IS NOT NULL
	DROP VIEW dbo.AvgOPerZoo;
GO

IF OBJECT_ID('AvgFPerZoo', 'V') IS NOT NULL
	DROP VIEW dbo.AvgFPerZoo;
GO

IF OBJECT_ID('AvgMPerZoo', 'V') IS NOT NULL
	DROP VIEW dbo.AvgMPerZoo;
GO

IF OBJECT_ID('NumChicksPair') IS NOT NULL
	DROP FUNCTION dbo.NumChicksPair;
GO

IF OBJECT_ID('NumChicksMale') IS NOT NULL
	DROP FUNCTION dbo.NumChicksMale;
GO

IF OBJECT_ID('NumChicksFemale') IS NOT NULL
	DROP FUNCTION dbo.NumChicksFemale;
GO

-- Creating the Zoo table
CREATE TABLE Zoo (
	-- Columns for the Zoo table
	ZooID varchar(10) NOT NULL,
	ZooName varchar(100) NOT NULL,
	AcctBalance decimal(6,2) NOT NULL,
	-- Constraints on the Zoo table
	CONSTRAINT PK_Zoo PRIMARY KEY (ZooID),
	CONSTRAINT U1_Zoo UNIQUE(ZooName)
)
-- End creating the Zoo table

-- Adding data to the Zoo table
INSERT INTO Zoo(ZooID, ZooName, AcctBalance)
	VALUES
		('ADBN', 'Audubon Zoo', 1000.00),
		('BUFF', 'Buffalo Zoo', 1000.00),
		('CALG', 'Calgary Zoo', 1000.00),
		('DALL', 'Dallas Zoo', 1000.00),
		('ERIE', 'Erie Zoo', 1000.00)

-- Creating the Wild table
CREATE TABLE Wild (
	-- Columns for the Wild table
	WildID varchar(10) NOT NULL,
	WildDescription varchar(100) NOT NULL,
	-- Constraints on the Wild table
	CONSTRAINT PK_Wild PRIMARY KEY (WildID),
	CONSTRAINT U1_Wild UNIQUE(WildDescription)
)
-- End creating the Wild table

-- Adding data to the Wild table
INSERT INTO Wild(WildID, WildDescription)
	VALUES
		('BAYOU', 'Bayou Sauvage National Wildlife Refuge'),
		('NYDEC', 'New York State Dept. of Environmental Conservation'),
		('CWRS', 'Calgary Wildlife Rehabilitation Society'),
		('FOSSIL', 'Fossil Rim Wildlife Center'),
		('WRCPA', 'Wild Resource Conservation Program, PA')

SELECT * FROM Wild

-- Creating the Bird table
CREATE TABLE Bird (
	-- Columns for the Bird table
	BandID int identity NOT NULL,
	MatingPairID char(8),
	WildID varchar(10),
	Birthdate date,
	Gender char(1) NOT NULL,
	ZooID varchar(10),
	EstAge decimal(2,1) NOT NULL,
	Price decimal(4,2) NOT NULL,
	-- Constraints on the Bird table
	CONSTRAINT PK_Bird PRIMARY KEY (BandID),
	CONSTRAINT FK1_Bird	FOREIGN KEY (ZooID) REFERENCES Zoo(ZooID),
	CONSTRAINT FK2_Bird FOREIGN KEY (WildID) REFERENCES Wild(WildID)
)
-- End creating the Bird table

-- Adding data to the Bird table
INSERT INTO Bird(Gender, ZooID, EstAge, Price)
	VALUES
		('F', 'ADBN', 2.0, 25.00),
		('M', 'ADBN', 2.5, 20.00),
		('F', 'BUFF', 3.0, 25.00),
		('M', 'BUFF', 3.5, 20.00),
		('F', 'ADBN', 4.0, 25.00),
		('F', 'CALG', 2.0, 25.00),
		('M', 'CALG', 2.5, 20.00),
		('F', 'DALL', 3.0, 25.00),
		('M', 'DALL', 3.5, 20.00),
		('F', 'ERIE', 4.0, 25.00),
		('F', 'ERIE', 3.0, 25.00),
		('M', 'ERIE', 3.5, 20.00)

SELECT Gender, ZooID, EstAge FROM Bird

-- Creating the Mating Pair table
CREATE TABLE Mating_Pair (
	-- Columns for the Mating Pair table
	MatingPairID char(8) NOT NULL,
	BandID_M int NOT NULL,
	BandID_F int NOT NULL,
	Birthdate date
	-- Constraints on the Mating Pair table
	CONSTRAINT PK_Mating_Pair PRIMARY KEY (MatingPairID)
)
-- Add Foreign Key Constraints from Bird table to Mating_Pair table
ALTER TABLE Mating_Pair
ADD CONSTRAINT FK1_Mating_Pair FOREIGN KEY (BandID_M) REFERENCES Bird(BandID),
	CONSTRAINT FK2_Mating_Pair FOREIGN KEY (BandID_F) REFERENCES Bird(BandID)
-- End creating the Mating Pair table

-- Adding data to Mating_Pair table
INSERT INTO Mating_Pair(MatingPairID, BandID_M, BandID_F, Birthdate)
	VALUES
		('2, 1', 2, 1, '2018-11-20'),
		('2, 5', 2, 5, '2018-11-28'),
		('4, 3', 4, 3, '2018-09-14'),
		('7, 6', 7, 6, '2018-01-01'),
		('9, 8', 9, 8, '2018-12-25'),
		('9, 4', 9, 4, '2018-07-03'),
		('12, 10', 12, 10, '2018-05-04'),
		('12, 11', 12, 11, '2018-07-11')

SELECT * FROM Mating_Pair

-- Adding more data (offspring) to Bird table
INSERT INTO Bird(MatingPairID, Birthdate, Gender, ZooID, EstAge, Price)
	VALUES
		('2, 1', '2018-11-20', 'F', 'ADBN', 0.5, 25.00),
		('2, 1', '2018-11-20', 'F', 'ADBN', 0.5, 25.00),
		('2, 1', '2018-11-20', 'M', 'ADBN', 0.5, 20.00),
		('2, 5', '2018-11-28', 'F', 'ADBN', 0.5, 25.00),
		('2, 5', '2018-11-28', 'M', 'ADBN', 0.5, 20.00),
		('2, 5', '2018-11-28', 'M', 'ADBN', 0.5, 20.00),
		('2, 5', '2018-11-28', 'M', 'ADBN', 0.5, 20.00),
		('4, 3', '2018-09-14', 'M', 'BUFF', 1.0, 20.00),
		('4, 3', '2018-09-14', 'F', 'BUFF', 1.0, 25.00),
		('4, 3', '2018-09-14', 'M', 'BUFF', 1.0, 20.00),
		('4, 3', '2018-09-14', 'M', 'BUFF', 1.0, 20.00),
		('4, 3', '2018-09-14', 'M', 'BUFF', 1.0, 20.00),
		('7, 6', '2018-01-01', 'F', 'CALG', 1.5, 25.00),
		('7, 6', '2018-01-01', 'F', 'CALG', 1.5, 25.00),
		('9, 4', '2018-07-03', 'F', 'DALL', 1.0, 25.00),
		('9, 4', '2018-07-03', 'M', 'DALL', 1.0, 20.00),
		('9, 4', '2018-07-03', 'M', 'DALL', 1.0, 20.00),
		('9, 4', '2018-07-03', 'M', 'DALL', 1.0, 20.00),
		('9, 8', '2018-12-25', 'M', 'DALL', 0.5, 20.00),
		('9, 8', '2018-12-25', 'F', 'DALL', 0.5, 25.00),
		('9, 8', '2018-12-25', 'M', 'DALL', 0.5, 20.00),
		('9, 8', '2018-12-25', 'M', 'DALL', 0.5, 20.00),
		('9, 8', '2018-12-25', 'M', 'DALL', 0.5, 20.00),
		('9, 8', '2018-12-25', 'F', 'DALL', 0.5, 25.00),
		('12, 10', '2018-05-04', 'F', 'ERIE', 1.5, 25.00),
		('12, 10', '2018-05-04', 'F', 'ERIE', 1.5, 25.00),
		('12, 10', '2018-05-04', 'M', 'ERIE', 1.5, 20.00),
		('12, 11', '2018-07-11', 'F', 'ERIE', 1.0, 25.00),
		('12, 11', '2018-07-11', 'M', 'ERIE', 1.0, 20.00),
		('12, 11', '2018-07-11', 'M', 'ERIE', 1.0, 20.00),
		('12, 11', '2018-07-11', 'M', 'ERIE', 1.0, 20.00),
		('12, 11', '2018-07-11', 'F', 'ERIE', 1.0, 25.00)

-- Creating the Transaction table
CREATE TABLE "Transaction" (
	-- Columns for the Transaction table
	TransactionID int identity NOT NULL,
	BuyingZooID varchar(10) NOT NULL,
	SellingZooID varchar(10) NOT NULL,
	BandID int NOT NULL,
	Price decimal(4,2) NOT NUll,
	-- Constraints on the Transaction table
	CONSTRAINT PK_Transaction PRIMARY KEY (TransactionID),
	CONSTRAINT FK1_Transaction FOREIGN KEY (BuyingZooID) REFERENCES Zoo(ZooID),
	CONSTRAINT FK2_Transaction FOREIGN KEY (SellingZooID) REFERENCES Zoo(ZooID),
	CONSTRAINT FK3_Transaction FOREIGN KEY (BandID) REFERENCES Bird(BandID)
)
-- End creating the Transaction table

GO
-- Create Transaction ("BuySell") Procedure
CREATE PROCEDURE BuySell(@buyingZoo varchar(10), @sellingZoo varchar(10), @bandID int) AS
BEGIN
	DECLARE @transID int
	SELECT @transID = TransactionID FROM "Transaction"
	WHERE	BuyingZooID = @buyingZoo
	DECLARE @price decimal(4,2)
	SELECT @price = Price FROM Bird
	WHERE	BandID = @bandID
	INSERT INTO "Transaction" (BuyingZooID, SellingZooID, BandID, Price)
	VALUES (@buyingZoo, @sellingZoo, @bandID, @price)
-- Update AcctBalance(s) in Zoo table
	UPDATE Zoo
	SET AcctBalance = AcctBalance - (SELECT Price FROM Bird WHERE BandID = @bandID)
	WHERE ZooID = @buyingZoo;
	UPDATE Zoo
	SET AcctBalance = AcctBalance + (SELECT Price FROM Bird WHERE BandID = @bandID)
	WHERE ZooID = @sellingZoo
-- Update Bird location (ZooID)
	UPDATE Bird
	SET ZooID = @buyingZoo
	WHERE BandID = @bandID
-- Return TransactionID
	RETURN SCOPE_IDENTITY()
END
GO

-- Creating data for the "Transaction" table
EXEC BuySell'ADBN', 'BUFF', 2
EXEC BuySell'DALL', 'BUFF', 4
EXEC BuySell'CALG', 'ADBN', 1
EXEC BuySell'BUFF', 'ADBN', 3
EXEC BuySell'ERIE', 'ADBN', 5

SELECT * FROM "Transaction"

SELECT * FROM Zoo

SELECT * FROM Bird

GO
 --Create WildRelease Procedure
CREATE PROCEDURE WildRelease(@bandID int, @wildID varchar(10)) AS
BEGIN
-- Update Bird location (WildID)
	UPDATE Bird
	SET WildID = @wildID
		, ZooID = NULL
	WHERE BandID = @bandID
END
GO

EXEC WildRelease 1, BAYOU

GO

CREATE FUNCTION dbo.NumChicksPair(@matingPairID char(8))
RETURNS int AS -- COUNT() is an integer value, so return it as an int
BEGIN
	DECLARE @returnValue int -- matches the function's return type
	SELECT @returnValue = COUNT(*) FROM Bird
	WHERE Bird.MatingPairID = @matingPairID
	RETURN @returnValue
END
GO

--DATA QUESTIONS

	--1. DATA QUESTION Who is the most prolific pair?
CREATE VIEW MostProlificPair AS
SELECT DISTINCT Bird.MatingPairID AS 'Mating Pair ID'
	, Bird.Birthdate AS 'Birthdate'
	, dbo.NumChicksPair(MatingPairID) AS NumberofChicks
FROM Bird WHERE MatingPairID IS NOT NULL
--ORDER BY NumberofChicks DESC
GO

	--2. DATA QUESTION Most Prolific Male/Female

--NumChicksMale Function and SELECT DISTINCT 
CREATE FUNCTION dbo.NumChicksMale(@bandID_M int)
RETURNS int AS -- COUNT() is an integer value, so return it as an int
BEGIN
	DECLARE @returnValue int -- matches the function's return type
	SELECT @returnValue = COUNT(*) FROM Mating_Pair
	INNER JOIN Bird ON Mating_Pair.MatingPairID = Bird.MatingPairID
	WHERE Mating_Pair.BandID_M = @bandID_M
	RETURN @returnValue
END
GO

SELECT DISTINCT Mating_Pair.BandID_M AS 'Male BandID'
	, dbo.NumChicksMale(BandID_M) AS 'Number of Chicks'
FROM Mating_Pair
	INNER JOIN Bird ON Mating_Pair.MatingPairID = Bird.MatingPairID
	WHERE BandID_M IS NOT NULL
	ORDER BY 'Number of Chicks' DESC

--Most Prolific Female FUNCTION and SELECT DISTINCT
GO
CREATE FUNCTION dbo.NumChicksFemale(@bandID_F int)
RETURNS int AS -- COUNT() is an integer value, so return it as an int
BEGIN
	DECLARE @returnValue int -- matches the function's return type
	SELECT @returnValue = COUNT(*) FROM Mating_Pair
	INNER JOIN Bird ON Mating_Pair.MatingPairID = Bird.MatingPairID
	WHERE Mating_Pair.BandID_F = @bandID_F
	RETURN @returnValue
END
GO

SELECT DISTINCT Mating_Pair.BandID_F AS 'Female BandID'
	, dbo.NumChicksFemale(BandID_F) AS 'Number of Chicks'
FROM Mating_Pair
	INNER JOIN Bird ON Mating_Pair.MatingPairID = Bird.MatingPairID
	WHERE BandID_F IS NOT NULL
	ORDER BY 'Number of Chicks' DESC

	--3. DATA QUESTION Average number of offspring per zoo (current location)
GO
CREATE VIEW AvgOPerZoo AS
SELECT COUNT(BandID) AS Offspring, ZooID
FROM Bird 
WHERE MatingPairID IS NOT NULL
GROUP BY ZooID
GO

SELECT AVG(Offspring) AS 'Avg. Offspring per Zoo'
FROM AvgOPerZoo

	--4. DATA QUESTION Average number of Male/Female offspring per zoo
GO
CREATE VIEW AvgFPerZoo AS 
SELECT COUNT(Gender) AS FemaleOffspring, ZooID
FROM Bird 
WHERE  Gender = 'F' AND MatingPairID IS NOT NULL
GROUP BY ZooID
GO

SELECT AVG(FemaleOffSpring) AS 'Avg. Female Offspring per Zoo'
FROM AvgFPerZoo

GO
CREATE VIEW AvgMPerZoo AS
SELECT COUNT(Gender) AS MaleOffspring, ZooID
FROM Bird 
WHERE Gender = 'M' AND MatingPairID IS NOT NULL
GROUP BY ZooID
GO

SELECT AVG(MaleOffspring) AS 'Avg. Male Offspring per Zoo'
FROM AvgMPerZoo

	--5. DATA QUESTION VIEW ZooRevenue 
SELECT AcctBalance, ZooName
FROM Zoo
ORDER BY AcctBalance DESC
