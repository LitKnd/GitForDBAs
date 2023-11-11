
-- Stored procedure to insert progress logs
CREATE PROCEDURE dbo.Insert_Hobby_Logs
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
