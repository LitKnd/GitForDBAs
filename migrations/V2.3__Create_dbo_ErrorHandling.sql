SET XACT_ABORT ON;
GO
BEGIN TRAN

    CREATE TABLE dbo.ErrorHandling (
        ErrorHandlingId INT IDENTITY NOT NULL,
        Declaration nvarchar(1000) NULL,
        CONSTRAINT PK_ErrorHandling PRIMARY KEY CLUSTERED (ErrorHandlingId)
    );
    GO


    --Check transaction state before we proceed
    IF @@TRANCOUNT <> 1
    BEGIN
        DECLARE @ErrorMessage AS NVARCHAR(4000);
        SET @ErrorMessage
            = N'Transaction in an invalid or closed state (@@TRANCOUNT=' + CAST(@@TRANCOUNT AS NVARCHAR(10))
            + N'). Exactly 1 transaction should be open at this point.  Rolling-back any pending transactions.';
        RAISERROR(@ErrorMessage, 16, 127);
        RETURN;
    END;
  

    -- This should throw an error
    ALTER TABLE dbo.ErrorHandling DROP COLUMN doesntexist
    GO

    --Check transaction state before we proceed
    exec dbo.TranCheck @expected_trancount = 1;

    -- IF @@TRANCOUNT <> 1
    -- BEGIN
    --     DECLARE @ErrorMessage AS NVARCHAR(4000);
    --     SET @ErrorMessage
    --         = N'Transaction in an invalid or closed state (@@TRANCOUNT=' + CAST(@@TRANCOUNT AS NVARCHAR(10))
    --         + N'). Exactly 1 transaction should be open at this point.  Rolling-back any pending transactions.';
    --     RAISERROR(@ErrorMessage, 16, 127);
    --     RETURN;
    -- END;

    ALTER TABLE dbo.ErrorHandling ADD ThisShouldNotRun bit null
    GO



COMMIT TRANSACTION