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
-- Stored procedure to insert a new hobby
CREATE OR ALTER PROCEDURE dbo.AddHobby 
    @HobbyName NVARCHAR(100),
    @Description NVARCHAR(500) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Hobbies WHERE HobbyName = @HobbyName)
    BEGIN
        INSERT INTO Hobbies (HobbyName, Description)
        VALUES (@HobbyName, @Description);
    END
END;
GO
-- Stored procedure to insert progress logs
CREATE PROCEDURE InsertProgressLog
    @HobbyName NVARCHAR(100),
    @LogDate DATE,
    @HoursSpent FLOAT,
    @MilestoneAchieved NVARCHAR(500) = NULL
AS
BEGIN
    DECLARE @HobbyId INT;

    SELECT @HobbyId = HobbyId FROM Hobbies WHERE HobbyName = @HobbyName;

    IF @HobbyId IS NOT NULL
    BEGIN
        INSERT INTO HobbyLogs (HobbyId, LogDate, HoursSpent, MilestoneAchieved)
        VALUES (@HobbyId, @LogDate, @HoursSpent, @MilestoneAchieved);
    END
    ELSE
    BEGIN
        PRINT 'Hobby not found';
    END
END;
GO
-- Stored procedure to summarize data
CREATE OR ALTER PROCEDURE dbo.SummarizeData 
    @HobbyName NVARCHAR(100)
AS
BEGIN
    SELECT 
        h.HobbyName,
        COUNT(p.LogId) AS TotalLogs,
        SUM(p.HoursSpent) AS TotalHoursSpent,
        COUNT(p.MilestoneAchieved) AS MilestonesAchieved
    FROM 
        Hobbies h
    JOIN 
        HobbyLogs p ON h.HobbyId = p.HobbyId
    WHERE 
        h.HobbyName = @HobbyName
    GROUP BY 
        h.HobbyName;
END;
