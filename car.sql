
/*
Car Rental Management System - SQL Server Script
Author: ChatGPT
Date: 2025-10-05

Contents:
1) Safety: drop existing tables in dependency order (commented)
2) DDL: create tables, PKs, FKs, constraints, indexes
3) Seed: insert at least 5 rows per table
4) Read queries
5) Update queries
6) Delete queries
*/

/* ------------------------------------------------------------
1) (Optional) DROP old objects — uncomment if you need a reset
---------------------------------------------------------------
DROP TABLE IF EXISTS dbo.Maintenance;
DROP TABLE IF EXISTS dbo.Reservation;
DROP TABLE IF EXISTS dbo.Location;
DROP TABLE IF EXISTS dbo.Insurance;
DROP TABLE IF EXISTS dbo.Payment;
DROP TABLE IF EXISTS dbo.Booking;
DROP TABLE IF EXISTS dbo.Customer;
DROP TABLE IF EXISTS dbo.Car;
GO
*/

/* ------------------------------------------------------------
2) DDL
-------------------------------------------------------------*/

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dbo')
BEGIN
    EXEC('CREATE SCHEMA dbo');
END
GO

-- CAR
CREATE TABLE dbo.Car (
    CarID           INT IDENTITY(1,1) PRIMARY KEY,
    CarModel        VARCHAR(100)       NOT NULL,
    Manufacturer    VARCHAR(100)       NOT NULL,
    [Year]          SMALLINT           NOT NULL CHECK ([Year] BETWEEN 1990 AND YEAR(GETDATE()) + 1),
    Color           VARCHAR(50)        NOT NULL,
    RentalRate      DECIMAL(10,2)      NOT NULL CHECK (RentalRate >= 0),
    Availability    BIT                NOT NULL DEFAULT 1
);
GO

-- CUSTOMER
CREATE TABLE dbo.Customer (
    CustomerID      INT IDENTITY(1,1) PRIMARY KEY,
    FirstName       VARCHAR(60)  NOT NULL,
    LastName        VARCHAR(60)  NOT NULL,
    Email           VARCHAR(120) NOT NULL UNIQUE,
    PhoneNumber     VARCHAR(30)  NOT NULL,
    [Address]       VARCHAR(200) NULL
);
GO

-- BOOKING
CREATE TABLE dbo.Booking (
    BookingID       INT IDENTITY(1,1) PRIMARY KEY,
    CarID           INT            NOT NULL,
    CustomerID      INT            NOT NULL,
    RentalStartDate DATE           NOT NULL,
    RentalEndDate   DATE           NOT NULL,
    TotalAmount     DECIMAL(10,2)  NOT NULL CHECK (TotalAmount >= 0),
    CONSTRAINT FK_Booking_Car       FOREIGN KEY (CarID)      REFERENCES dbo.Car (CarID),
    CONSTRAINT FK_Booking_Customer  FOREIGN KEY (CustomerID) REFERENCES dbo.Customer (CustomerID),
    CONSTRAINT CK_Booking_DateRange CHECK (RentalEndDate >= RentalStartDate)
);
GO

-- PAYMENT
CREATE TABLE dbo.Payment (
    PaymentID       INT IDENTITY(1,1) PRIMARY KEY,
    BookingID       INT            NOT NULL,
    PaymentDate     DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
    Amount          DECIMAL(10,2)  NOT NULL CHECK (Amount >= 0),
    PaymentMethod   VARCHAR(30)    NOT NULL,
    CONSTRAINT FK_Payment_Booking FOREIGN KEY (BookingID) REFERENCES dbo.Booking (BookingID),
    CONSTRAINT CK_Payment_Method CHECK (PaymentMethod IN ('Cash','Card','MobileMoney','BankTransfer'))
);
GO

-- INSURANCE
CREATE TABLE dbo.Insurance (
    InsuranceID     INT IDENTITY(1,1) PRIMARY KEY,
    CarID           INT           NOT NULL,
    InsuranceProvider VARCHAR(120) NOT NULL,
    PolicyNumber    VARCHAR(80)   NOT NULL,
    StartDate       DATE          NOT NULL,
    EndDate         DATE          NOT NULL,
    CONSTRAINT FK_Insurance_Car FOREIGN KEY (CarID) REFERENCES dbo.Car (CarID),
    CONSTRAINT UQ_Insurance UNIQUE (CarID, PolicyNumber),
    CONSTRAINT CK_Insurance_DateRange CHECK (EndDate >= StartDate)
);
GO

-- LOCATION (as car-location history / assignments; latest row can represent current)
CREATE TABLE dbo.Location (
    LocationID      INT IDENTITY(1,1) PRIMARY KEY,
    CarID           INT            NOT NULL,
    LocationName    VARCHAR(120)   NOT NULL,
    [Address]       VARCHAR(200)   NULL,
    ContactNumber   VARCHAR(30)    NULL,
    CONSTRAINT FK_Location_Car FOREIGN KEY (CarID) REFERENCES dbo.Car (CarID)
);
GO

-- RESERVATION (pre-booking hold)
CREATE TABLE dbo.Reservation (
    ReservationID   INT IDENTITY(1,1) PRIMARY KEY,
    CarID           INT           NOT NULL,
    CustomerID      INT           NOT NULL,
    ReservationDate DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    PickupDate      DATETIME2     NOT NULL,
    ReturnDate      DATETIME2     NOT NULL,
    CONSTRAINT FK_Reservation_Car      FOREIGN KEY (CarID)      REFERENCES dbo.Car (CarID),
    CONSTRAINT FK_Reservation_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Customer (CustomerID),
    CONSTRAINT CK_Reservation_DateRange CHECK (ReturnDate >= PickupDate)
);
GO

-- MAINTENANCE
CREATE TABLE dbo.Maintenance (
    MaintenanceID   INT IDENTITY(1,1) PRIMARY KEY,
    CarID           INT           NOT NULL,
    MaintenanceDate DATE          NOT NULL,
    [Description]   VARCHAR(200)  NOT NULL,
    Cost            DECIMAL(10,2) NOT NULL CHECK (Cost >= 0),
    CONSTRAINT FK_Maintenance_Car FOREIGN KEY (CarID) REFERENCES dbo.Car (CarID)
);
GO

-- Helpful indexes
CREATE INDEX IX_Booking_Customer ON dbo.Booking (CustomerID, RentalStartDate);
CREATE INDEX IX_Payment_Booking  ON dbo.Payment (BookingID, PaymentDate);
CREATE INDEX IX_Reservation_Car  ON dbo.Reservation (CarID, PickupDate);
GO

/* ------------------------------------------------------------
3) Seed Data (>=5 rows per table)
-------------------------------------------------------------*/

-- Cars
INSERT INTO dbo.Car (CarModel, Manufacturer, [Year], Color, RentalRate, Availability) VALUES
('Yaris',         'Toyota', 2019, 'White',  35.00, 1),
('Civic',         'Honda',  2021, 'Blue',   45.00, 1),
('Corolla',       'Toyota', 2020, 'Black',  40.00, 1),
('Model 3',       'Tesla',  2022, 'Red',    80.00, 1),
('CX-5',          'Mazda',  2018, 'Silver', 55.00, 1),
('Pajero',        'Mitsubishi', 2017, 'Grey', 60.00, 1);
GO

-- Customers
INSERT INTO dbo.Customer (FirstName, LastName, Email, PhoneNumber, [Address]) VALUES
('Alice',  'Wanjiku', 'alice.wanjiku@example.com', '+254700111111', 'Nairobi'),
('Brian',  'Otieno',  'brian.otieno@example.com',  '+254700222222', 'Kisumu'),
('Carol',  'Njeri',   'carol.njeri@example.com',   '+254700333333', 'Nyeri'),
('David',  'Mutua',   'david.mutua@example.com',   '+254700444444', 'Mombasa'),
('Eunice', 'Achieng', 'eunice.achieng@example.com','+254700555555', 'Nakuru'),
('Felix',  'Kimani',  'felix.kimani@example.com',  '+254700666666', 'Eldoret');
GO

-- Bookings
INSERT INTO dbo.Booking (CarID, CustomerID, RentalStartDate, RentalEndDate, TotalAmount) VALUES
(1, 1, '2025-09-01', '2025-09-05',  35.00 * 4),
(2, 2, '2025-09-10', '2025-09-12',  45.00 * 2),
(3, 3, '2025-09-15', '2025-09-20',  40.00 * 5),
(4, 4, '2025-09-18', '2025-09-19',  80.00 * 1),
(5, 5, '2025-09-21', '2025-09-24',  55.00 * 3),
(6, 6, '2025-09-25', '2025-09-27',  60.00 * 2);
GO

-- Payments (multiple per booking to illustrate 1-M)
INSERT INTO dbo.Payment (BookingID, PaymentDate, Amount, PaymentMethod) VALUES
(1, '2025-09-01T08:00:00',  70.00, 'MobileMoney'),
(1, '2025-09-04T18:30:00',  70.00, 'Card'),
(2, '2025-09-10T09:15:00',  45.00, 'Cash'),
(2, '2025-09-12T17:40:00',  45.00, 'Cash'),
(3, '2025-09-15T10:05:00', 120.00, 'BankTransfer'),
(3, '2025-09-20T19:25:00',  80.00, 'Card');
GO

-- Insurance (at least one per car, unique PolicyNumber per Car)
INSERT INTO dbo.Insurance (CarID, InsuranceProvider, PolicyNumber, StartDate, EndDate) VALUES
(1, 'Britam',  'POL-TY-001', '2025-01-01', '2025-12-31'),
(2, 'Jubilee', 'POL-HO-002', '2025-02-01', '2026-01-31'),
(3, 'AAR',     'POL-TY-003', '2025-03-15', '2026-03-14'),
(4, 'Britam',  'POL-TS-004', '2025-04-01', '2026-03-31'),
(5, 'CIC',     'POL-MZ-005', '2025-05-10', '2026-05-09'),
(6, 'Jubilee', 'POL-MI-006', '2025-06-01', '2026-05-31');
GO

-- Location (history/assignments per car)
INSERT INTO dbo.Location (CarID, LocationName, [Address], ContactNumber) VALUES
(1, 'Nairobi CBD',   'Kenyatta Ave 10',   '+254111100001'),
(1, 'JKIA Branch',   'Airport South Rd',  '+254111100002'),
(2, 'Kisumu Pier',   'Oginga Odinga St',  '+254111100003'),
(3, 'Nyeri Town',    'Kenyatta Rd 22',    '+254111100004'),
(4, 'Mombasa Nyali', 'Links Rd 15',       '+254111100005'),
(5, 'Nakuru CBD',    'Kenyatta Ave 5',    '+254111100006');
GO

-- Reservations
INSERT INTO dbo.Reservation (CarID, CustomerID, ReservationDate, PickupDate, ReturnDate) VALUES
(1, 2, '2025-08-30T12:00:00', '2025-09-02T09:00:00', '2025-09-05T10:00:00'),
(2, 3, '2025-09-05T08:15:00', '2025-09-11T09:00:00', '2025-09-12T09:00:00'),
(3, 4, '2025-09-10T14:20:00', '2025-09-16T08:00:00', '2025-09-20T08:00:00'),
(4, 5, '2025-09-12T09:45:00', '2025-09-18T08:00:00', '2025-09-19T08:00:00'),
(5, 1, '2025-09-18T16:30:00', '2025-09-22T08:00:00', '2025-09-24T08:00:00'),
(6, 6, '2025-09-20T10:00:00', '2025-09-26T08:00:00', '2025-09-27T20:00:00');
GO

-- Maintenance
INSERT INTO dbo.Maintenance (CarID, MaintenanceDate, [Description], Cost) VALUES
(1, '2025-07-10', 'Oil change & filters', 60.00),
(2, '2025-07-15', 'Brake pads replacement', 120.00),
(3, '2025-08-01', 'Tire rotation & balancing', 80.00),
(4, '2025-08-20', 'Software update & inspection', 150.00),
(5, '2025-09-01', 'AC servicing', 90.00),
(6, '2025-09-05', 'Battery replacement', 140.00);
GO

/* ------------------------------------------------------------
4) READ (sample SELECTs)
-------------------------------------------------------------*/

-- 4.1 List all cars and their latest known location (based on max LocationID per Car)
WITH LatestLoc AS (
    SELECT CarID, MAX(LocationID) AS MaxLocID
    FROM dbo.Location
    GROUP BY CarID
)
SELECT c.CarID, c.Manufacturer, c.CarModel, c.[Year], c.Color, c.RentalRate,
       llc.LocationName, llc.[Address]
FROM dbo.Car c
LEFT JOIN LatestLoc ll ON ll.CarID = c.CarID
LEFT JOIN dbo.Location llc ON llc.LocationID = ll.MaxLocID
ORDER BY c.CarID;

-- 4.2 Current & upcoming bookings, with customer and car
SELECT b.BookingID, c.Manufacturer, c.CarModel, cust.FirstName, cust.LastName,
       b.RentalStartDate, b.RentalEndDate, b.TotalAmount
FROM dbo.Booking b
JOIN dbo.Car c    ON c.CarID = b.CarID
JOIN dbo.Customer cust ON cust.CustomerID = b.CustomerID
ORDER BY b.RentalStartDate DESC;

-- 4.3 Payments per booking (aggregate)
SELECT b.BookingID,
       SUM(p.Amount) AS TotalPaid,
       COUNT(*)      AS PaymentCount
FROM dbo.Booking b
LEFT JOIN dbo.Payment p ON p.BookingID = b.BookingID
GROUP BY b.BookingID
ORDER BY b.BookingID;

-- 4.4 Insurance validity snapshot (find policies expiring within next 60 days from today)
SELECT i.*, c.Manufacturer, c.CarModel
FROM dbo.Insurance i
JOIN dbo.Car c ON c.CarID = i.CarID
WHERE i.EndDate BETWEEN CONVERT(date, GETDATE()) AND DATEADD(DAY, 60, CONVERT(date, GETDATE()))
ORDER BY i.EndDate;

/* ------------------------------------------------------------
5) UPDATE (sample updates)
-------------------------------------------------------------*/

-- 5.1 Mark a car unavailable when a booking starts (example for CarID=1)
UPDATE dbo.Car SET Availability = 0
WHERE CarID = 1;

-- 5.2 Update customer phone number
UPDATE dbo.Customer SET PhoneNumber = '+254711111111'
WHERE Email = 'alice.wanjiku@example.com';

-- 5.3 Adjust booking total amount (e.g., add a late fee)
UPDATE dbo.Booking SET TotalAmount = TotalAmount + 10.00
WHERE BookingID = 2;

/* ------------------------------------------------------------
6) DELETE (sample deletes)
-------------------------------------------------------------*/

-- 6.1 Remove a specific reservation that was cancelled (example)
DELETE FROM dbo.Reservation
WHERE ReservationID = 2;

-- 6.2 Remove a maintenance record entered in error (example)
DELETE FROM dbo.Maintenance
WHERE MaintenanceID = 6;

-- (Note) For production, consider soft deletes instead of hard deletes where appropriate.
