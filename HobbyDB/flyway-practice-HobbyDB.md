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



## Add a new migration for the following script
## Name the migration: V01.2__ix_hobbies_HobbyName_INCLUDES.sql

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.Hobbies') AND name = 'IX_Hobbies_HobbyName_INCLUDES')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Hobbies_HobbyName_INCLUDES
    ON dbo.Hobbies (HobbyName)
    INCLUDE (Favorite)
    WITH (ONLINE = ON);
END
GO


## Deploy it to the target database

flyway info
flyway migrate


## Let's say these changes have been deployed to all our environments
## We want to modify IX_Hobbies_HobbyName_INCLUDES and remove the included column
## What do we do? 