
-- Stored procedure to insert a new hobby
CREATE OR ALTER PROCEDURE dbo.add_hobby 
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