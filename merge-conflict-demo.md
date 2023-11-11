

## Let's practice merge conflicts

### Using a terminal start in the main branch:


git checkout main


### Create a new branch and check it out. 

git branch change1

git checkout change1

## make a change to the comments in this file. Save it, add it, commit it.

.AdminDB/migrations/R__get_database_size_space_used.sql

git status
git add .
git commit -m "updating description"

## check out main, then create a new branch named change2

Q: What would the new branch contain if we created it while we had change1 checked out after committing a change?

We can created a branch and check it out in one command with the -b parameter:

git checkout main
git checkout -b change2

## make a different change to the comments in this file. Save it, add it, commit it.

.AdminDB/migrations/R__get_database_size_space_used.sql

Instead of doing "git add ." or adding individual files, we can use -a on commit if we want.

git commit -m "updating documentation" -a

## check out main and merge the changes from change2

git checkout main
git merge change2

## merge the changes from change1 and get a merge conflict

git merge change1

## Resolve the merge conflict using the editors and then delete the branches

git branch
git branch -d change1
git branch -d change2