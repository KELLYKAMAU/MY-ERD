-- Car
CREATE TABLE Car (
  CarID        INTEGER PRIMARY KEY,
  CarModel     VARCHAR(100) NOT NULL,
  Manufacturer VARCHAR(100) NOT NULL,
  Year         INTEGER NOT NULL,
  Color        VARCHAR(50) NOT NULL,
  RentalRate   DECIMAL(10,2) NOT NULL,
  Availability BOOLEAN NOT NULL
);

-- Customer
CREATE TABLE Customer (
  CustomerID   INTEGER PRIMARY KEY,
  FirstName    VARCHAR(60) NOT NULL,
  LastName     VARCHAR(60) NOT NULL,
  Email        VARCHAR(120) NOT NULL UNIQUE,
  PhoneNumber  VARCHAR(30) NOT NULL,
  Address      VARCHAR(200)
);

-- Booking (Car 1-M Booking, Customer 1-M Booking)
CREATE TABLE Booking (
  BookingID       INTEGER PRIMARY KEY,
  CarID           INTEGER NOT NULL,
  CustomerID      INTEGER NOT NULL,
  RentalStartDate DATE NOT NULL,
  RentalEndDate   DATE NOT NULL,
  TotalAmount     DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (CarID)     REFERENCES Car(CarID),
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- Payment (Booking 1-M Payment)
CREATE TABLE Payment (
  PaymentID     INTEGER PRIMARY KEY,
  BookingID     INTEGER NOT NULL,
  PaymentDate   TIMESTAMP NOT NULL,
  Amount        DECIMAL(10,2) NOT NULL,
  PaymentMethod VARCHAR(30) NOT NULL,
  FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)
);

-- Insurance (Car 1-M Insurance)
CREATE TABLE Insurance (
  InsuranceID       INTEGER PRIMARY KEY,
  CarID             INTEGER NOT NULL,
  InsuranceProvider VARCHAR(120) NOT NULL,
  PolicyNumber      VARCHAR(80) NOT NULL,
  StartDate         DATE NOT NULL,
  EndDate           DATE NOT NULL,
  UNIQUE (CarID, PolicyNumber),
  FOREIGN KEY (CarID) REFERENCES Car(CarID)
);

-- Location (treated as car-location assignments/history)
CREATE TABLE Location (
  LocationID    INTEGER PRIMARY KEY,
  CarID         INTEGER NOT NULL,
  LocationName  VARCHAR(120) NOT NULL,
  Address       VARCHAR(200),
  ContactNumber VARCHAR(30),
  FOREIGN KEY (CarID) REFERENCES Car(CarID)
);

-- Reservation (pre-booking hold; Car 1-M, Customer 1-M)
CREATE TABLE Reservation (
  ReservationID  INTEGER PRIMARY KEY,
  CarID          INTEGER NOT NULL,
  CustomerID     INTEGER NOT NULL,
  ReservationDate TIMESTAMP NOT NULL,
  PickupDate     TIMESTAMP NOT NULL,
  ReturnDate     TIMESTAMP NOT NULL,
  FOREIGN KEY (CarID) REFERENCES Car(CarID),
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- Maintenance (Car 1-M Maintenance)
CREATE TABLE Maintenance (
  MaintenanceID  INTEGER PRIMARY KEY,
  CarID          INTEGER NOT NULL,
  MaintenanceDate DATE NOT NULL,
  Description     VARCHAR(200) NOT NULL,
  Cost            DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (CarID) REFERENCES Car(CarID)
);