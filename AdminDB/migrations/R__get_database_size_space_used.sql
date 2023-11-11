SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************
Purpose:
Returns size and space used for all dbs.

Usage:
exec dbo.get_database_size_space_used
***************************/


CREATE OR ALTER PROCEDURE [dbo].[get_database_size_space_used]
    @debug BIT = 0
AS

    DECLARE @database_id int, @database_name nvarchar(128), @dsql nvarchar(MAX);

    /* Create temporary objects */
    drop table if exists #db_summary;
    create table #db_summary
    (
        database_id INT,
        database_name NVARCHAR(128),
        user_access_desc NVARCHAR(60),
        state_desc NVARCHAR(60),
        is_read_only BIT,
        is_auto_shrink_on BIT,
        size_gb MONEY,
        data_file_count INT,
        log_file_count INT,
        filestream_count INT
    )
    DROP TABLE IF EXISTS #db_file_stats;
    CREATE TABLE #db_file_stats
    (
        database_id int not null,
        data_files_reserved_gb money,
        data_files_used_gb money,
        data_files_empty_gb money,
    )
    drop table if exists #db_log_info;
    create table #db_log_info
    (
        database_id int not null,
        log_files_gb bigint not null,
        log_files_used_gb bigint not null
    );

    /* Get easy things from sys.master_files */
    insert #db_summary
    SELECT
        d.database_id,
        d.name as database_name,
        d.user_access_desc,
        d.state_desc,
        d.is_read_only,
        d.is_auto_shrink_on,
        SUM(mf.size) * 8. /1024 /1024 as size_gb,
        SUM( case mf.type when 0 then 1 else 0 end) as data_file_count,
        SUM( case mf.type when 1 then 1 else 0 end) as log_file_count,
        SUM( case mf.type when 2 then 1 else 0 end) as filestream_count
    from sys.master_files as mf
        join sys.databases as d on mf.database_id = d.database_id
    group by 
        d.database_id,
        d.name,
        d.user_access_desc,
        d.state_desc,
        d.is_read_only,
        d.is_auto_shrink_on;

    /* Loop through online databases to collect info from per-db views */
    DECLARE db_cursor CURSOR FOR
        SELECT database_id, [name]
    FROM sys.databases
    WHERE state_desc = 'ONLINE';

    OPEN db_cursor
    FETCH NEXT FROM db_cursor INTO @database_id, @database_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @dsql = '
            SELECT 
                ' + cast(@database_id as nvarchar(5)) + ' AS database_id,
                CAST(SUM(
                    CASE df.type when 0 then su.total_page_count ELSE 0 END) * 8. /1024 /1024 AS MONEY) AS data_files_reserved_gb,
                CAST(SUM(
                    CASE df.type when 0 then (su.total_page_count - su.unallocated_extent_page_count) ELSE 0 END) * 8. /1024 /1024 AS MONEY) AS data_files_used_gb,
                CAST(SUM(
                        CAST (su.unallocated_extent_page_count AS bigint)
                    ) * 8. /1024 /1024 AS MONEY) AS data_files_empty_gb
            FROM ' + QUOTENAME(@database_name) + '.sys.database_files AS df
            JOIN ' + QUOTENAME(@database_name) + '.sys.dm_db_file_space_usage as su ON df.file_id = su.file_id'

        IF @debug=1
            PRINT @dsql
        ELSE
        INSERT #db_file_stats
            (database_id, data_files_reserved_gb, data_files_used_gb, data_files_empty_gb)
        EXEC sp_executesql @dsql;

        SET @dsql = '
            SELECT
                ' + cast(@database_id as nvarchar(5)) + ' AS database_id,
                CAST(SUM(total_log_size_in_bytes) /1024. /1024 /1024 AS MONEY) AS log_files_gb,
                CAST(SUM(used_log_space_in_bytes) /1024. /1024 /1024 AS MONEY) AS log_files_used_gb
            FROM ' + QUOTENAME(@database_name) + '.sys.dm_db_log_space_usage AS lu
            WHERE lu.database_id = ' + cast(@database_id as nvarchar) + ';'

        IF @debug=1
            PRINT @dsql
        ELSE
        INSERT #db_log_info
            (database_id, log_files_gb, log_files_used_gb)
        EXEC sp_executesql @dsql;

        FETCH NEXT FROM db_cursor INTO @database_id, @database_name;
    END

    CLOSE db_cursor;
    DEALLOCATE db_cursor;


    SELECT
        d.database_id,
        d.database_name,
        d.user_access_desc,
        d.state_desc,
        d.is_read_only,
        d.is_auto_shrink_on,
        d.size_gb,
        fs.data_files_reserved_gb,
        fs.data_files_empty_gb,
        fs.data_files_used_gb,
        d.data_file_count,
        d.log_file_count,
        li.log_files_gb,
        li.log_files_used_gb,
        d.filestream_count
    FROM #db_summary as d
        LEFT JOIN #db_file_stats as fs on d.database_id = fs.database_id
        LEFT JOIN #db_log_info as li on d.database_id = li.database_id;
GO


