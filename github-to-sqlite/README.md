Uses [github-to-sqlite](https://github.com/dogsheep/github-to-sqlite) to import data from Github
into a local sqlite database. Data from this database can be imported into the Memex.

1. Run `setup.sh` to create an auth token. If you want to get information about private
   repositories, use the `repo` permission when creating the token.

2. Run `import-database.sh` to import data. This should be part of a regular import schedule.
