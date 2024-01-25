
CREATE DATABASE Flights_db_325905206

------------------------------------------------------------------------------------

USE Flights_db_325905206

CREATE TABLE AirLines_tbl
(
	AirLineCode smallint identity(1,1) primary key,
	AirLineName  varchar(20) unique
)
GO

CREATE TABLE Planes_tbl
(
	PlaneCode int identity(100,1) primary key,
	AirLineCode smallint references AirLines_tbl,
	NumberOfSeats int default 300,
)
GO

CREATE TABLE Destinations_tbl
(
	DestinationCode int identity(100, 1) primary key,
	DestinationName  varchar(20) unique NOT NULL,
)
GO

CREATE TABLE Flights_tbl
(
	FlightCode varchar (10) primary key,
	PlaneCode int references Planes_tbl,
	DestinationCode int references Destinations_tbl,
	TicketPrice money,
	FlightDate date,
	ContinueFlightCode varchar (10) 
)
GO

CREATE TABLE Passengers_tbl
(
	PassengerCode int identity(100,1) primary key,
	FirstName  varchar (10),
	LastName  varchar (10),
	Phone  varchar (10) CHECK (LEN(Phone)=10) 
)
GO

CREATE TABLE OrderTicket_tbl
(
	OrderCode int identity(100,1) primary key,
	FlightCode varchar (10) references Flights_tbl,
	PassengerCode int references Passengers_tbl,
	OrderDate date default GETDATE(),
	SeatNum int   
)
GO

CREATE TRIGGER Shabbos_trigger ON Flights_tbl
For Insert, Update
AS  
	BEGIN
		DECLARE @Day  VARCHAR(10) 
		DECLARE @Date DATE
		SELECT @Date = FlightDate FROM inserted
		SELECT @Day = DATENAME(DW,@Date) 
		IF @Day = 'Saturday'
		BEGIN
			UPDATE Flights_tbl
			SET FlightDate = DATEADD(DD,1,@Date) 
			FROM Flights_tbl f JOIN inserted i 
			ON f.FlightCode = i.FlightCode
		END
		ELSE 
			IF @Day='Friday'
			BEGIN
				UPDATE Flights_tbl
				SET FlightDate = DATEADD(DD,2,@Date) 
				FROM Flights_tbl f JOIN inserted i 
				ON f.FlightCode = i.FlightCode
			END 
	END
GO

CREATE TRIGGER Seat_trigger ON OrderTicket_tbl
For Insert, Update
AS  
	BEGIN
		DECLARE @SeatNum  int 
		DECLARE @MaxSeat  int 
		SELECT @SeatNum = SeatNum FROM inserted
		SELECT @MaxSeat = p.NumberOfSeats FROM Planes_tbl p JOIN Flights_tbl f ON p.PlaneCode = f.PlaneCode JOIN OrderTicket_tbl o ON o.FlightCode = f.FlightCode JOIN inserted i ON i.OrderCode = o.OrderCode 
		IF @SeatNum > @MaxSeat 
			ROLLBACK
	END
GO
	
CREATE TRIGGER OrderDate_trigger ON OrderTicket_tbl
For Insert, Update
AS  
	BEGIN
		DECLARE @FlightDate  DATE 
		DECLARE @OrderDate  DATE 
		SELECT @FlightDate = f.FlightDate 
		FROM Flights_tbl f JOIN inserted i
		ON f.FlightCode = i.FlightCode

		SELECT @OrderDate = i.OrderDate
		FROM Flights_tbl f JOIN inserted i
		ON f.FlightCode = i.FlightCode		
		
		IF @OrderDate > @FlightDate 
			ROLLBACK
	END
GO
------------------------------------------------------------------------------------

CREATE PROCEDURE InsertPassengerDetails (@FirstName  varchar (10), @LastName  varchar (10), @Phone  varchar (10)) 
AS
	BEGIN 
		INSERT INTO Passengers_tbl
		VALUES(@FirstName,@LastName,@Phone)
	END
GO

EXECUTE InsertPassengerDetails 'דונלד', 'טראמפ','0911111111' 
------------------------------------------------------------------------------------

CREATE PROCEDURE UpdateFlightDate (@FlightCode varchar(10), @NewDate date) 
AS
	BEGIN 
		UPDATE  Flights_tbl
		SET FlightDate = @NewDate
		WHERE FlightCode = @FlightCode
	END
GO

EXECUTE UpdateFlightDate '6H664', '2023-03-17'
------------------------------------------------------------------------------------
CREATE FUNCTION ContinueFlight (@FlightCode varchar(10)) RETURNS TABLE
AS 
	RETURN (SELECT f1.FlightCode, d.DestinationName, f1.FlightDate, f1.TicketPrice*0.9 AS 'Spasial Ticket Price'
		    FROM (Flights_tbl f1 JOIN Flights_tbl f2 ON f1.FlightCode = f2.ContinueFlightCode) JOIN Destinations_tbl d ON f1.DestinationCode = d.DestinationCode
			WHERE f2.FlightCode = @FlightCode)
GO

SELECT *
FROM ContinueFlight ('BA165')

------------------------------------------------------------------------------------
CREATE FUNCTION NumberOfPassengers (@FlightCode varchar (10))
RETURNS INT
AS
	BEGIN
		DECLARE @Count INT
		SELECT @Count =  COUNT(*)
		FROM OrderTicket_tbl
		WHERE FlightCode = @FlightCode 
		RETURN @Count
	END
GO

PRINT DBO.NumberOfPassengers ('BA1359')

------------------------------------------------------------------------------------
CREATE VIEW FlightDetails
AS
	SELECT p.FirstName+' '+p.LastName AS Name, o.FlightCode AS Flight, a.AirLineName AS AirLine, d.DestinationName AS Destination, f.FlightDate AS Date, o.SeatNum AS Seat 
	FROM (((OrderTicket_tbl o JOIN Passengers_tbl p ON o.PassengerCode = p.PassengerCode) JOIN Flights_tbl f ON o.FlightCode = f.FlightCode) 
    JOIN Destinations_tbl d ON f.DestinationCode = d.DestinationCode) JOIN Planes_tbl pl ON f.PlaneCode = pl.PlaneCode JOIN AirLines_tbl a ON pl.AirLineCode = a.AirLineCode 
GO 

SELECT * 
FROM FlightDetails 
WHERE Name = 'דוד רובינסון'

------------------------------------------------------------------------------------

		DECLARE @RW SMALLINT
		SELECT @RW = COUNT(*)
		FROM Passengers_tbl
		SET @RW = CAST(RAND()*@RW AS INT) + 1
		
		SELECT qry.FirstName +' '+ qry.LastName AS Name, qry.Phone,
		CASE 
			WHEN SUBSTRING(Phone,1,5) IN ('05832','05276','05531') THEN 'תשלח הודעה קולית'
			WHEN Phone IS NULL THEN 'אנא צור איתנו קשר'
			ELSE 'תשלח הודעת טקסט '
		END 'פרטי זכייה'
		FROM (SELECT *, ROW_NUMBER() OVER(ORDER BY PassengerCode) AS RN
			  FROM Passengers_tbl) qry
		WHERE qry.RN = @RW
		 	
------------------------------------------------------------------------------------	
CREATE VIEW SumPlanesOfAirLines
AS
	SELECT AirLineName, CASE 
							WHEN COUNT(*) = 1 THEN 'SMALL'
							WHEN COUNT(*) BETWEEN 2 AND 3 THEN 'MEDIUM'
							WHEN COUNT(*)>3 THEN 'BIG'
						END as CompanySize
	FROM AirLines_tbl a JOIN Planes_tbl p ON a.AirLineCode=p.AirLineCode
	GROUP BY a.AirLineCode, a.AirLineName
GO

SELECT *
FROM SumPlanesOfAirLines

------------------------------------------------------------------------------------
INSERT INTO AirLines_tbl
VALUES ('EL AL')
GO

INSERT INTO AirLines_tbl
VALUES ('British Airways')
GO

INSERT INTO AirLines_tbl
VALUES ('Delta')
GO

INSERT INTO AirLines_tbl
VALUES ('Wizz Air')
GO		 

INSERT INTO AirLines_tbl
VALUES ('United Airlines')
GO	

INSERT INTO AirLines_tbl
VALUES ('Eazy Jet')
GO	

INSERT INTO AirLines_tbl
VALUES ('Lufthansa')
GO	

INSERT INTO AirLines_tbl
VALUES ('Israir')
GO	
	
------------------------------------------------------------------------------------

INSERT INTO Planes_tbl
VALUES (1,282)
GO	

INSERT INTO Planes_tbl
VALUES (1,320)
GO	

INSERT INTO Planes_tbl
VALUES (1,250)
GO	

INSERT INTO Planes_tbl
VALUES (2,238)
GO	

INSERT INTO Planes_tbl
VALUES (2,285)
GO	

INSERT INTO Planes_tbl
VALUES (3,175)
GO

INSERT INTO Planes_tbl
VALUES (3,190)
GO

INSERT INTO Planes_tbl
VALUES (4,271)
GO

INSERT INTO Planes_tbl
VALUES (4,362)
GO

INSERT INTO Planes_tbl
VALUES (5,660)
GO

INSERT INTO Planes_tbl
VALUES (6,166)
GO

INSERT INTO Planes_tbl
VALUES (7,279)
GO	
--------------------------------------------------------------------

INSERT INTO Destinations_tbl
VALUES('בודפשט') 
GO

INSERT INTO Destinations_tbl
VALUES('דובאי') 
GO

INSERT INTO Destinations_tbl
VALUES('אילת') 
GO

INSERT INTO Destinations_tbl
VALUES('אמסטרדם') 
GO

INSERT INTO Destinations_tbl
VALUES('לונדון') 
GO

INSERT INTO Destinations_tbl
VALUES('וינה') 
GO

INSERT INTO Destinations_tbl
VALUES('פריז') 
GO

INSERT INTO Destinations_tbl
VALUES('ברלין') 
GO

INSERT INTO Destinations_tbl
VALUES('ניו יורק') 
GO

INSERT INTO Destinations_tbl
VALUES('פלורידה') 
GO

INSERT INTO Destinations_tbl
VALUES('קפריסין') 
GO
--------------------------------------------------------------------

INSERT INTO Flights_tbl
VALUES('BA165',105,107,398,'02/01/2023','LY324') 
GO

INSERT INTO Flights_tbl
VALUES('W62811',100,102,224,'09/02/2023',NULL) 
GO

INSERT INTO Flights_tbl
VALUES('LAUN125X',107,103,246,'01/25/2023',NULL) 
GO

INSERT INTO Flights_tbl
VALUES('6H664',101,101,156,'03/16/2023',NULL) 
GO

INSERT INTO Flights_tbl
VALUES('LY324',103,106,196,'06/15/2023',NULL) 
GO

INSERT INTO Flights_tbl
VALUES('VA9240',102,108,828,'05/12/2023',NULL) 
GO

INSERT INTO Flights_tbl
VALUES('EZY1827',106,105,457,'12/17/2022','LAUN125X') 
GO

INSERT INTO Flights_tbl
VALUES('BA458C',103,103,326,'03/01/2023',NULL) 
GO

INSERT INTO Flights_tbl
VALUES('W4719',108,110,76,'12/29/2022',NULL) 
GO

INSERT INTO Flights_tbl
VALUES('BA1359',105,104,308,'01/12/2023','UA6540') 
GO

INSERT INTO Flights_tbl
VALUES('UA6540',106,109,470,'01/12/2023',NULL) 
GO
--------------------------------------------------------------------
INSERT INTO Passengers_tbl
VALUES('תמר','מילר','0583288976') 
GO

INSERT INTO Passengers_tbl
VALUES('דוד','רובינסון','0587514952') 
GO

INSERT INTO Passengers_tbl
VALUES('רוברט','פראנק','0524816855') 
GO

INSERT INTO Passengers_tbl
VALUES('גון','גולד','0586261268') 
GO

INSERT INTO Passengers_tbl
VALUES('דני','גרין','0583278197') 
GO

INSERT INTO Passengers_tbl
VALUES('חנה','בראון','0586428318') 
GO

INSERT INTO Passengers_tbl
VALUES('עליזה','שחור','0527643342') 
GO

INSERT INTO Passengers_tbl
VALUES('שולמית','פרידמן','0527618052') 
GO

INSERT INTO Passengers_tbl
VALUES('יעלי','שימל','0583282718') 
GO

INSERT INTO Passengers_tbl
VALUES('מוחמד','אבו חליל',NULL) 
GO

--------------------------------------------------------------------
INSERT INTO OrderTicket_tbl
VALUES('BA458C',100,'01/01/2023',10) 
GO

INSERT INTO OrderTicket_tbl
VALUES('UA6540',101,'12/11/2022',67) 
GO

INSERT INTO OrderTicket_tbl
VALUES('LY324',102,'4/27/2023',238) 
GO

INSERT INTO OrderTicket_tbl
VALUES('BA1359',103,'12/29/2022',68) 
GO

INSERT INTO OrderTicket_tbl
VALUES('W62811',104,'08/03/2023',184) 
GO

INSERT INTO OrderTicket_tbl
VALUES('6H664',105,'03/16/2022',223) 
GO

INSERT INTO OrderTicket_tbl
VALUES('LAUN125X',106,'01/24/2023',171) 
GO

INSERT INTO OrderTicket_tbl
VALUES('LY324',107,'04/15/2023',52) 
GO

INSERT INTO OrderTicket_tbl
VALUES('LY324',108,'04/15/2023',53) 
GO

INSERT INTO OrderTicket_tbl
VALUES('6H664',109,'03/01/2023',298) 
GO

INSERT INTO OrderTicket_tbl
VALUES('BA1359',101,'12/11/2022',150) 
GO