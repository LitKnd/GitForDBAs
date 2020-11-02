SET XACT_ABORT ON;
GO
BEGIN TRAN

    CREATE TABLE dbo.HelloWorld (
        HelloWorldId INT IDENTITY NOT NULL,
        Declaration nvarchar(1000) NULL,
        CONSTRAINT PK_HelloWorld PRIMARY KEY CLUSTERED (HelloWorldId)
    );


COMMIT TRAN