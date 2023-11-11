-- Stored procedure to summarize data
CREATE OR ALTER PROCEDURE dbo.summarize_data 
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
