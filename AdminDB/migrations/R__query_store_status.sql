SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************
Purpose: 
Return query store options for all databases

Usage:
exec dbo.get_query_store_options
***************************/


CREATE OR ALTER PROCEDURE [dbo].[get_query_store_options]
    @debug BIT = 0
AS

SET NOCOUNT ON;

DECLARE @database_id INT;
DECLARE @database_name NVARCHAR(128);
DECLARE @dsql NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR
    SELECT database_id, [name]
FROM sys.databases
WHERE state_desc = 'ONLINE';

DROP TABLE IF EXISTS #query_store_options;
CREATE TABLE #query_store_options
(
    database_id INT,
    database_name NVARCHAR(128),
    desired_state_desc NVARCHAR(60),
    actual_state_desc NVARCHAR(60),
    actual_state_additional_info NVARCHAR(60),
    current_storage_size_gb MONEY,
    flush_interval_seconds INT,
    interval_length_minutes INT,
    max_storage_size_gb MONEY,
    stale_query_threshold_days INT,
    max_plans_per_query INT,
    query_capture_mode_desc NVARCHAR(60),
    size_based_cleanup_mode_desc NVARCHAR(60),
    wait_stats_capture_mode_desc NVARCHAR(60)
)

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @database_id, @database_name;

WHILE @@FETCH_STATUS = 0
BEGIN

    set @dsql = N'
    SELECT @database_id,
        @database_name,
        desired_state_desc,
        actual_state_desc,
        actual_state_additional_info,
        current_storage_size_mb/1024. as current_storage_size_gb,
        flush_interval_seconds,
        interval_length_minutes,
        max_storage_size_mb/1024. as max_storage_size_gb,
        stale_query_threshold_days,
        max_plans_per_query,
        query_capture_mode_desc,
        size_based_cleanup_mode_desc,
        wait_stats_capture_mode_desc
    from sys.database_query_store_options'

    IF @debug=1
        PRINT @dsql;
    ELSE
    insert #query_store_options
    exec sp_executesql @dsql , N'@database_id INT, @database_name NVARCHAR(128)', @database_id, @database_name;

    FETCH NEXT FROM db_cursor INTO @database_id, @database_name;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

SELECT *
FROM #query_store_options
ORDER BY 1,2;