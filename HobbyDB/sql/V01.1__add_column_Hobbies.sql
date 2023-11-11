IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Hobbies') AND name = 'Favorite')
BEGIN
    ALTER TABLE dbo.Hobbies
    ADD Favorite BIT NOT NULL DEFAULT 0;
END
GO