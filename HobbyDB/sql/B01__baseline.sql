-- Drop existing tables if they exist
IF OBJECT_ID('dbo.HobbyLogs', 'U') IS NOT NULL
    DROP TABLE HobbyLogs;

IF OBJECT_ID('dbo.Hobbies', 'U') IS NOT NULL
    DROP TABLE Hobbies;

-- Hobbies table definition
CREATE TABLE dbo.Hobbies
(
    HobbyId INT PRIMARY KEY IDENTITY(1,1),
    HobbyName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    CONSTRAINT UQ_HobbyName UNIQUE (HobbyName)
);
GO
-- HobbyLogs table definition
CREATE TABLE dbo.HobbyLogs
(
    LogId INT PRIMARY KEY IDENTITY(1,1),
    HobbyId INT FOREIGN KEY REFERENCES Hobbies(HobbyId),
    LogDate DATE NOT NULL,
    HoursSpent FLOAT NOT NULL CHECK (HoursSpent > 0),
    MilestoneAchieved NVARCHAR(500)
);
GO