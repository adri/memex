#!/usr/bin/env bash
# Imports all data
import.sh sqlite-to-json/git-notes.sh
import.sh sqlite-to-json/iMessage.sh
import.sh sqlite-to-json/MoneyMoney.sh
import.sh sqlite-to-json/Photos.sh
import.sh sqlite-to-json/Safari.sh
import.sh sqlite-to-json/terminal.sh

./github-to-sqlite/import-database.sh
import.sh sqlite-to-json/github.sh

./twitter-to-sqlite/import-database.sh
import.sh sqlite-to-json/twitter.sh
