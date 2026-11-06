USE MASTER    
CREATE DATABASE test   -- to create database named "test".
ON PRIMARY   -- to add files with mdf,ndf and ldf extention.
(NAME=Firefighter_Station1,   -- the name of primary file.
FILENAME= 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\DATA\Firefighter_Station1.mdf',  -- the path of the primary file.
SIZE=10MB,  -- initial size of the primary file
MAXSIZE=15MB,   -- the maxsize of the primary file.
FILEGROWTH=20%),  -- the percentage of growth for the primary file.

(NAME=Firefighter_Station2,   -- the name of secondary file.
FILENAME= 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\DATA\Firefighter_Station2.ndf',  -- the path of the secondary file.
SIZE=10MB,  -- initial size of the secondary file
MAXSIZE=150MB,  -- the maxsize of the secondary file.
FILEGROWTH=50MB) -- increasing size that the secondary file will increase with.

LOG ON   -- to create log files.
(NAME=Firefighter_Station_log1, -- the name of the log file.
filename= 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\DATA\Firefighter_Station_log1.ldf',  -- the path of the log file.
SIZE=50MB,  -- the initial size of the log file.
MAXSIZE=100MB,  -- the maxsize of the log file.
FILEGROWTH=10MB),  -- increasing size that the secondary file will increase with.

(NAME=Firefighter_Station_log2, -- the name of the log file.
FILENAME=  'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\DATA\Firefighter_Station_log2.ldf',  -- the path of the log file.
SIZE=30MB,  -- the initial size of the log file.
MAXSIZE=200MB,  -- the maxsize size of the log file.
FILEGROWTH=20%)-- increasing size that the secondary file will increase with.

-- Tables

-- Firefighters Table
USE test;
CREATE TABLE Firefighter (
    FirefighterID INT IDENTITY(1,1),  -- start from 1 and increament by 1 ...
    StationID     INT           NOT NULL,   -- foregn key to Station.
    FullName      VARCHAR(100)  NOT NULL,   -- the name of the firefighter .
    NationalID    CHAR(14)      NOT NULL,   -- ID to the firefighter .
    Phone         VARCHAR(15)   NULL,       -- nemberto the firefighter .
    Salary DECIMAL(10,2) NOT NULL,  -- salary starts from 10 and increment by 2.
    --RankTitle     VARCHAR(30)   NOT NULL,   -- 
    --HireDate      DATE          NOT NULL
        CONSTRAINT DF_Firefighter_HireDate DEFAULT GETDATE(), -- if it's a null value , the the program set today as a Hiredate. 
         Status   VARCHAR(15)   NOT NULL  -- to check the status of the firefighters.
        CONSTRAINT DF_Firefighter_Status DEFAULT 'active',  -- set the defaulte value "Active" automaticly.

    CONSTRAINT PK_Firefighter PRIMARY KEY (FirefighterID),  -- set ID as a primary key for the table.
    CONSTRAINT UQ_Firefighter_NationalID UNIQUE (NationalID),  -- set NationalID as a unique value.
    CONSTRAINT CK_Firefighter_Salary CHECK (Salary > 0),   -- check if the salary more than 0 or not.
    CONSTRAINT CK_Firefighter_Status
        CHECK (Status IN ('active', 'anLeave', 'retired')) ); -- to check firefighter's status

-- Truck Table
CREATE TABLE Truck (
    TruckID     INT IDENTITY(1,1),  -- truck ID starts from 1 and increment by 1.
    StationID   INT NOT NULL,   -- foreign key to Station .
    PlateNumber   VARCHAR(15) NOT NULL,  -- set the Platform number as a character.
    TruckType    VARCHAR(30) NOT NULL,  -- set the truck type as a character.
    WaterCapacityLiters INT         NOT NULL,  -- set the capacity of the truck as a integer number.
    Status  VARCHAR(15) NOT NULL  
        CONSTRAINT DF_Truck_Status DEFAULT 'available', -- set the status of the truck "Available" as a default value.

    CONSTRAINT PK_Truck PRIMARY KEY (TruckID), -- set truckID as a primary key.
    CONSTRAINT UQ_Truck_PlateNumber UNIQUE (PlateNumber),  -- set Truck_PlateNumber as a unique value.
    CONSTRAINT CK_Truck_WaterCapacity CHECK (WaterCapacityLiters > 0),  -- chech if the truck capacity more than 0 or not. 
    CONSTRAINT CK_Truck_Status
        CHECK (Status IN ('available', 'on mission', 'maintenance')) );  -- check truck status.
