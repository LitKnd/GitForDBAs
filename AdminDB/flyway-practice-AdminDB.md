## Install flyway if you don't have it, and add it to the path

Free flyway community edition works for this demo.

https://www.red-gate.com/products/flyway/community/download/

## Test that flyway works. You may want to use flyway desktop to help write the jdbc string for your target, or just edit this one.

Look at setup in the flyway.conf file.
Note: Don't store your passwords in version control for anything that matters at all. 
You can use .gitignore to prevent files from being synced to the repo

flyway info


## Run a "clean" against the target to reset it. WARNING: this drops everything in the target

flyway clean

## Deploy migrations to the target

flyway migrate

flyway info

## Make a change to a script under /sql, save it, and migrate


flyway migrate

flyway info


## Add a new migration for the following script
## Name the migration: R__get_query_store_forced_plans.sql





SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**********************
exec dbo.[get_query_store_forced_plans]
************************/


CREATE OR ALTER PROCEDURE [dbo].[get_query_store_forced_plans]
    @debug BIT = 0
AS

SET NOCOUNT ON;

DECLARE @database_id INT;
DECLARE @database_name NVARCHAR(128);
DECLARE @dsql NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR
    SELECT database_id, [name]
FROM sys.databases
WHERE state_desc = 'ONLINE' 
and database_id > 2;

DROP TABLE IF EXISTS #forced_plans;
CREATE TABLE #forced_plans
(
    database_name NVARCHAR(128),
	query_id int,
	plan_forcing_type_desc NVARCHAR(128),
	plan_type NVARCHAR(128),
	query_plan_xml xml
)

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @database_id, @database_name;

WHILE @@FETCH_STATUS = 0
BEGIN

    set @dsql = N'
	SELECT DB_NAME(),
		qsq.query_id, 
		qsp.plan_forcing_type_desc,
		qsp.plan_type,
		cast (qsp.query_plan as xml) as query_plan_xml
	FROM '  + QUOTENAME (@database_name) + N'.sys.query_store_query as qsq
	join '  + QUOTENAME (@database_name) + N'.sys.query_store_plan as qsp on qsq.query_id=qsp.query_id
	where qsp.is_forced_plan=1;'

    IF @debug=1
        PRINT @dsql;
    ELSE
    insert #forced_plans
    exec sp_executesql @dsql , N'@database_id INT, @database_name NVARCHAR(128)', @database_id, @database_name;

    FETCH NEXT FROM db_cursor INTO @database_id, @database_name;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

SELECT *
FROM #forced_plans
ORDER BY 1,2;
GO

## Migrate 

flyway migrate


## Now delete R__get_query_store_forced_plans.sql

flyway info

flyway repair

flyway migrate