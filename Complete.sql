/* ============================================================
   Fire Station Database - SQL Server (corrected version)
   ============================================================ */

USE master;
GO

CREATE DATABASE test   -- database named "test"
ON PRIMARY             -- primary (.mdf) and secondary (.ndf) data files
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
LOG ON                 -- transaction log files (.ldf)
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
GO

USE test;
GO

/* ===================== TABLES ===================== */

-- Station (parent table, must be created first)
CREATE TABLE Station (
    StationID         INT IDENTITY(1,1),
    StationName       VARCHAR(100) NOT NULL,
    Address           VARCHAR(200) NOT NULL,
    City              VARCHAR(50)  NOT NULL,
    PhoneNumber       VARCHAR(15)  NOT NULL,
    NumberOfParkSlots INT          NOT NULL   -- number of trucks the station's park can take
        CONSTRAINT DF_Station_ParkSlots DEFAULT 0,
    FoundedDate       DATE         NOT NULL
        CONSTRAINT DF_Station_FoundedDate DEFAULT GETDATE(),
    Status            VARCHAR(20)  NOT NULL
        CONSTRAINT DF_Station_Status DEFAULT 'active',

    CONSTRAINT PK_Station PRIMARY KEY (StationID),
    CONSTRAINT UQ_Station_StationName UNIQUE (StationName),
    CONSTRAINT UQ_Station_Phone UNIQUE (PhoneNumber),
    CONSTRAINT CK_Station_ParkSlots CHECK (NumberOfParkSlots >= 0),
    CONSTRAINT CK_Station_Status CHECK (Status IN ('active', 'under renovation', 'closed'))
);
GO

-- Firefighter
CREATE TABLE Firefighter (
    FirefighterID INT IDENTITY(1,1),
    StationID     INT           NOT NULL,   -- FK to Station
    FullName      VARCHAR(100)  NOT NULL,
    NationalID    CHAR(14)      NOT NULL,
    Phone         VARCHAR(15)   NULL,
    Salary        DECIMAL(10,2) NOT NULL,
    RankTitle     VARCHAR(30)   NOT NULL,
    HireDate      DATE          NOT NULL
        CONSTRAINT DF_Firefighter_HireDate DEFAULT GETDATE(),
    Status        VARCHAR(15)   NOT NULL
        CONSTRAINT DF_Firefighter_Status DEFAULT 'active',

    CONSTRAINT PK_Firefighter PRIMARY KEY (FirefighterID),
    CONSTRAINT FK_Firefighter_Station FOREIGN KEY (StationID)
        REFERENCES Station (StationID),
    CONSTRAINT UQ_Firefighter_NationalID UNIQUE (NationalID),
    CONSTRAINT CK_Firefighter_Salary CHECK (Salary > 0),
    CONSTRAINT CK_Firefighter_Status CHECK (Status IN ('active', 'onLeave', 'retired'))
);
GO

-- Truck
CREATE TABLE Truck (
    TruckID             INT IDENTITY(1,1),
    StationID           INT         NOT NULL,   -- FK to Station
    PlateNumber         VARCHAR(15) NOT NULL,
    TruckType           VARCHAR(30) NOT NULL,
    WaterCapacityLiters INT         NOT NULL,
    Status              VARCHAR(15) NOT NULL
        CONSTRAINT DF_Truck_Status DEFAULT 'available',

    CONSTRAINT PK_Truck PRIMARY KEY (TruckID),
    CONSTRAINT FK_Truck_Station FOREIGN KEY (StationID)
        REFERENCES Station (StationID),
    CONSTRAINT UQ_Truck_PlateNumber UNIQUE (PlateNumber),
    CONSTRAINT CK_Truck_WaterCapacity CHECK (WaterCapacityLiters > 0),
    CONSTRAINT CK_Truck_Status CHECK (Status IN ('available', 'on mission', 'maintenance'))
);
GO

/* ===================== INCIDENTS PART ===================== */

CREATE TABLE IncidentType (
    IncidentTypeID INT IDENTITY(1,1),
    TypeName       VARCHAR(50)  NOT NULL,
    Description    VARCHAR(200) NULL,

    CONSTRAINT PK_IncidentType PRIMARY KEY (IncidentTypeID),
    CONSTRAINT UQ_IncidentType_TypeName UNIQUE (TypeName)
);
GO

INSERT INTO IncidentType (TypeName)
VALUES ('Building Fire'), ('Car Accident'), ('Rescue');
GO

CREATE TABLE Incidents (
    Incident_ID     INT IDENTITY(1,1),
    IncidentTypeID  INT NOT NULL,   -- FK to IncidentType
    StationID       INT NOT NULL,   -- FK to Station (responsible station)
    Address         VARCHAR(200)  NOT NULL,
    Reported_At     DATETIME      NOT NULL
        CONSTRAINT DF_Incident_ReportedAt DEFAULT GETDATE(),
    ClosedAt        DATETIME      NULL,
    DangerLevel     TINYINT       NOT NULL,   -- 1 (minor) to 5 (critical)
    CasualtiesCount INT           NOT NULL
        CONSTRAINT DF_Incident_Casualties DEFAULT 0,
    Damage          DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Incident_Damage DEFAULT 0,
    Status          VARCHAR(15)   NOT NULL
        CONSTRAINT DF_Incident_Status DEFAULT 'reported',

    CONSTRAINT PK_Incident PRIMARY KEY (Incident_ID),
    CONSTRAINT FK_Incident_IncidentType FOREIGN KEY (IncidentTypeID)
        REFERENCES IncidentType (IncidentTypeID),
    CONSTRAINT FK_Incident_Station FOREIGN KEY (StationID)
        REFERENCES Station (StationID),
    CONSTRAINT CK_Incident_DangerLevel CHECK (DangerLevel BETWEEN 1 AND 5),
    CONSTRAINT CK_Incident_Casualties  CHECK (CasualtiesCount >= 0),
    CONSTRAINT CK_Incident_Damage      CHECK (Damage >= 0),
    CONSTRAINT CK_Incident_Status      CHECK (Status IN ('reported', 'in progress', 'closed')),
    CONSTRAINT CK_Incident_Dates       CHECK (ClosedAt IS NULL OR ClosedAt >= Reported_At)
);
GO

-- Incident <-> Firefighter
CREATE TABLE Incident_Firefighter (
    Incident_ID    INT         NOT NULL,
    FirefighterID  INT         NOT NULL,
    RoleInIncident VARCHAR(30) NOT NULL
        CONSTRAINT DF_IncFF_Role DEFAULT 'responder',
    AssignedAt     DATETIME    NOT NULL
        CONSTRAINT DF_IncFF_AssignedAt DEFAULT GETDATE(),

    CONSTRAINT PK_Incident_Firefighter PRIMARY KEY (Incident_ID, FirefighterID),
    CONSTRAINT FK_IncFF_Incident FOREIGN KEY (Incident_ID)
        REFERENCES Incidents (Incident_ID),
    CONSTRAINT FK_IncFF_Firefighter FOREIGN KEY (FirefighterID)
        REFERENCES Firefighter (FirefighterID),
    CONSTRAINT CK_IncFF_Role CHECK (RoleInIncident IN ('commander', 'driver', 'responder', 'medic'))
);
GO

-- Incident <-> Truck
CREATE TABLE Incident_Truck (
    Incident_ID  INT      NOT NULL,
    TruckID      INT      NOT NULL,
    DispatchTime DATETIME NOT NULL
        CONSTRAINT DF_IncTruck_Dispatch DEFAULT GETDATE(),
    ArrivalTime  DATETIME NULL,

    CONSTRAINT PK_Incident_Truck PRIMARY KEY (Incident_ID, TruckID),
    CONSTRAINT FK_IncTruck_Incident FOREIGN KEY (Incident_ID)
        REFERENCES Incidents (Incident_ID),
    CONSTRAINT FK_IncTruck_Truck FOREIGN KEY (TruckID)
        REFERENCES Truck (TruckID),
    -- arrival cannot be before the truck was dispatched
    CONSTRAINT CK_IncTruck_Times CHECK (ArrivalTime IS NULL OR ArrivalTime >= DispatchTime)
);
GO

-- Reports
CREATE TABLE Reports (
    Report_ID          INT IDENTITY(1,1),
    Incident_ID        INT          NOT NULL,
    Report_Date        DATE         NOT NULL
        CONSTRAINT DF_Reports_Date DEFAULT GETDATE(),
    Report_Description VARCHAR(500) NULL,
    Reports_Status     VARCHAR(30)  NOT NULL
        CONSTRAINT DF_Reports_Status DEFAULT 'Pending',

    CONSTRAINT PK_Reports PRIMARY KEY (Report_ID),
    CONSTRAINT FK_Reports_Incident FOREIGN KEY (Incident_ID)
        REFERENCES Incidents (Incident_ID),
    CONSTRAINT CK_Reports_Status CHECK (Reports_Status IN ('Pending', 'Complete'))
);
GO

-- Equipment (AUTO_INCREMENT is MySQL; SQL Server uses IDENTITY)
CREATE TABLE Equipment (
    Equipment_ID   INT IDENTITY(1,1),
    Equipment_Name VARCHAR(100) NOT NULL,
    Quantity       INT          NOT NULL,

    CONSTRAINT PK_Equipment PRIMARY KEY (Equipment_ID),
    CONSTRAINT CK_Equipment_Quantity CHECK (Quantity >= 0)
);
GO
