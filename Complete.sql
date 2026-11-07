USE MASTER;

CREATE DATABASE test
ON PRIMARY
(
    NAME = Firefighter_Station1,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\DATA\Firefighter_Station1.mdf',
    SIZE = 10MB,
    MAXSIZE = 15MB,
    FILEGROWTH = 20%
),
(
    NAME = Firefighter_Station2,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\DATA\Firefighter_Station2.ndf',
    SIZE = 10MB,
    MAXSIZE = 150MB,
    FILEGROWTH = 50MB
)
LOG ON
(
    NAME = Firefighter_Station_log1,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\DATA\Firefighter_Station_log1.ldf',
    SIZE = 50MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 10MB
),
(
    NAME = Firefighter_Station_log2,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\DATA\Firefighter_Station_log2.ldf',
    SIZE = 30MB,
    MAXSIZE = 200MB,
    FILEGROWTH = 20%
);

USE test;

-- Station Table
CREATE TABLE Station (
    StationID INT IDENTITY(1,1),
    StationName VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    City VARCHAR(50) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL,
    NumberOfParkSlots INT NOT NULL
        CONSTRAINT DF_NOPS DEFAULT 0,
    FoundedDate DATE NOT NULL
        CONSTRAINT DF_Station_FoundationDate DEFAULT GETDATE(),
    Status VARCHAR(20) NOT NULL
        CONSTRAINT DF_Station_Status DEFAULT 'active',

    CONSTRAINT PK_Station PRIMARY KEY (StationID),
    CONSTRAINT UQ_Station_StationName UNIQUE (StationName),
    CONSTRAINT UQ_Station_Phone UNIQUE (PhoneNumber),
    CONSTRAINT CK_Station_Bays CHECK (NumberOfParkSlots >= 0),
    CONSTRAINT CK_Station_Status
        CHECK (Status IN ('active', 'under renovation', 'closed'))
);

-- Firefighter Table
CREATE TABLE Firefighter (
    FirefighterID INT IDENTITY(1,1),
    StationID INT NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    NationalID CHAR(14) NOT NULL,
    Phone VARCHAR(15) NULL,
    Salary DECIMAL(10,2) NOT NULL,
    RankTitle VARCHAR(30) NOT NULL,
    HireDate DATE NOT NULL
        CONSTRAINT DF_Firefighter_HireDate DEFAULT GETDATE(),
    Status VARCHAR(15) NOT NULL
        CONSTRAINT DF_Firefighter_Status DEFAULT 'active',

    CONSTRAINT PK_Firefighter PRIMARY KEY (FirefighterID),
    CONSTRAINT FK_Firefighter_Station FOREIGN KEY (StationID)
        REFERENCES Station (StationID),
    CONSTRAINT UQ_Firefighter_NationalID UNIQUE (NationalID),
    CONSTRAINT CK_Firefighter_Salary CHECK (Salary > 0),
    CONSTRAINT CK_Firefighter_Status
        CHECK (Status IN ('active', 'onLeave', 'retired'))
);

-- Truck Table
CREATE TABLE Truck (
    TruckID INT IDENTITY(1,1),
    StationID INT NOT NULL,
    PlateNumber VARCHAR(15) NOT NULL,
    TruckType VARCHAR(30) NOT NULL,
    WaterCapacityLiters INT NOT NULL,
    Status VARCHAR(15) NOT NULL
        CONSTRAINT DF_Truck_Status DEFAULT 'available',

    CONSTRAINT PK_Truck PRIMARY KEY (TruckID),
    CONSTRAINT FK_Truck_Station FOREIGN KEY (StationID)
        REFERENCES Station (StationID),
    CONSTRAINT UQ_Truck_PlateNumber UNIQUE (PlateNumber),
    CONSTRAINT CK_Truck_WaterCapacity CHECK (WaterCapacityLiters > 0),
    CONSTRAINT CK_Truck_Status
        CHECK (Status IN ('available', 'on mission', 'maintenance'))
);

-- IncidentType Table
CREATE TABLE IncidentType (
    IncidentTypeID INT IDENTITY(1,1),
    TypeName VARCHAR(50) NOT NULL,
    Description VARCHAR(200) NULL,

    CONSTRAINT PK_IncidentType PRIMARY KEY (IncidentTypeID),
    CONSTRAINT UQ_IncidentType_TypeName UNIQUE (TypeName)
);

-- Main Incident Table
CREATE TABLE Incidents (
    Incident_ID INT IDENTITY(1,1),
    IncidentTypeID INT NOT NULL,
    StationID INT NOT NULL,
    Address VARCHAR(200) NOT NULL,
    Reported_At DATETIME NOT NULL
        CONSTRAINT DF_Incident_ReportedAt DEFAULT GETDATE(),
    ClosedAt DATETIME NULL,
    DangerLevel TINYINT NOT NULL,
    CasualtiesCount INT NOT NULL
        CONSTRAINT DF_Incident_Casualties DEFAULT 0,
    Damage DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Incident_Damage DEFAULT 0,
    Status VARCHAR(15) NOT NULL
        CONSTRAINT DF_Incident_Status DEFAULT 'reported',

    CONSTRAINT PK_Incident PRIMARY KEY (Incident_ID),
    CONSTRAINT FK_Incident_IncidentType FOREIGN KEY (IncidentTypeID)
        REFERENCES IncidentType (IncidentTypeID),
    CONSTRAINT FK_Incident_Station FOREIGN KEY (StationID)
        REFERENCES Station (StationID),
    CONSTRAINT CK_Incident_DangerLevel CHECK (DangerLevel BETWEEN 1 AND 5),
    CONSTRAINT CK_Incident_Casualties CHECK (CasualtiesCount >= 0),
    CONSTRAINT CK_Incident_Damage CHECK (Damage >= 0),
    CONSTRAINT CK_Incident_Status
        CHECK (Status IN ('reported', 'in progress', 'closed')),
    CONSTRAINT CK_Incident_Dates
        CHECK (ClosedAt IS NULL OR ClosedAt >= Reported_At)
);

-- Equipment Table
CREATE TABLE Equipment (
    Equipment_ID INT IDENTITY(1,1) PRIMARY KEY,
    Equipment_Name VARCHAR(100) NOT NULL,
    Quantity INT NOT NULL
);

-- Reports Table
CREATE TABLE Reports (
    Report_ID INT IDENTITY(1,1) PRIMARY KEY,
    Incident_ID INT NOT NULL,
    Report_Date DATE DEFAULT GETDATE(),
    Report_Description VARCHAR(500),
    Reports_Status VARCHAR(30),

    CHECK (Reports_Status IN ('Pending', 'Complete')),

    FOREIGN KEY (Incident_ID)
        REFERENCES Incidents (Incident_ID)
);

-- Incident <-> Firefighter
CREATE TABLE Incident_Firefighter (
    Incident_ID INT NOT NULL,
    FirefighterID INT NOT NULL,
    RoleInIncident VARCHAR(30) NOT NULL
        CONSTRAINT DF_IncFF_Role DEFAULT 'responder',
    AssignedAt DATETIME NOT NULL
        CONSTRAINT DF_IncFF_AssignedAt DEFAULT GETDATE(),

    CONSTRAINT PK_Incident_Firefighter
        PRIMARY KEY (Incident_ID, FirefighterID),
    CONSTRAINT FK_IncFF_Incident FOREIGN KEY (Incident_ID)
        REFERENCES Incidents (Incident_ID),
    CONSTRAINT FK_IncFF_Firefighter FOREIGN KEY (FirefighterID)
        REFERENCES Firefighter (FirefighterID),
    CONSTRAINT CK_IncFF_Role
        CHECK (RoleInIncident IN ('commander', 'driver', 'responder', 'medic'))
);

-- Incident <-> Truck
CREATE TABLE Incident_Truck (
    Incident_ID INT NOT NULL,
    TruckID INT NOT NULL,
    DispatchTime DATETIME NOT NULL
        CONSTRAINT DF_IncTruck_Dispatch DEFAULT GETDATE(),
    ArrivalTime DATETIME NULL,

    CONSTRAINT PK_Incident_Truck
        PRIMARY KEY (Incident_ID, TruckID),
    CONSTRAINT FK_IncTruck_Incident FOREIGN KEY (Incident_ID)
        REFERENCES Incidents (Incident_ID),
    CONSTRAINT FK_IncTruck_Truck FOREIGN KEY (TruckID)
        REFERENCES Truck (TruckID),
    CONSTRAINT CK_IncTruck_Times
        CHECK (ArrivalTime IS NULL OR ArrivalTime >= DispatchTime)
);
