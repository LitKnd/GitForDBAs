CREATE OR ALTER PROC dbo.TranCheck @expected_trancount TINYINT
AS
IF @@TRANCOUNT <> @expected_trancount
BEGIN
    DECLARE @ErrorMessage AS NVARCHAR(4000);
    SET @ErrorMessage
        = N'Transaction in an invalid or closed state (@@TRANCOUNT=' + CAST(@@TRANCOUNT AS NVARCHAR(10))
          + N'). Exactly ' + CAST(@expected_trancount AS NVARCHAR(2))
          + N' transaction(s) should be open at this point.  Rolling back any pending transactions.';
    RAISERROR(@ErrorMessage, 16, 127);
    RETURN 0;
END;