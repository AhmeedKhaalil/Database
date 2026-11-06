Use master    
CREATE DATABASE test   -- to create database named "test".
ON PRIMARY   -- to add files with mdf,ndf and ldf extention.
(name=Firefighter_Station1,   -- the name of primary file.
filename= 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\DATA\Firefighter_Station1.mdf',  -- the path of the primary file.
size=10MB,  -- initial size of the primary file
maxsize=15MB,   -- the maxsize of the primary file.
filegrowth=20%),  -- the percentage of growth for the primary file.

(name=Firefighter_Station2,   -- the name of secondary file.
filename= 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\DATA\Firefighter_Station2.ndf',  -- the path of the secondary file.
size=10MB,  -- initial size of the secondary file
maxsize=150MB,  -- the maxsize of the secondary file.
filegrowth=50MB) -- increasing size that the secondary file will increase with.

LOG ON   -- to create log files.
(name=Firefighter_Station_log1, -- the name of the log file.
filename= 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\DATA\Firefighter_Station_log1.ldf',  -- the path of the log file.
size=50MB,  -- the initial size of the log file.
maxsize=100MB,  -- the maxsize of the log file.
filegrowth=10MB),  -- increasing size that the secondary file will increase with.

(name=Firefighter_Station_log2, -- the name of the log file.
filename=  'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\DATA\Firefighter_Station_log2.ldf',  -- the path of the log file.
size=30MB,  -- the initial size of the log file.
maxsize=200MB,  -- the maxsize size of the log file.
filegrowth=20%)-- increasing size that the secondary file will increase with.