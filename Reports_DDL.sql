CREATE TABLE Reports(
Report_ID INT IDENTITY(1,1) PRIMARY KEY,
Incident_ID INT NOT NULL,
Report_Date DATE DEFAULT GETDATE(),
Report_Description VARCHAR(500),
Reports_Status VARCHAR(30),
CHECK (Reports_Status IN('Pending','Complete')),
FOREIGN KEY (Incident_ID)
REFERENCES Incidents(Incident_ID)
);