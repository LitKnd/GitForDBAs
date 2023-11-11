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

