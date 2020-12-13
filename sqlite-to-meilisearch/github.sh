#!/usr/bin/env bash
# Imports stars from Github
# Needs github-to-sqlite database.

USER=${GITHUB_USER_NAME:=adri}

sqlite3 "github-to-sqlite/github.db" -readonly "
SELECT
    json_object(
        'provider', 'Github',
        'verb', 'liked',
        'id', 'github_' || repos.id,
        'date_month', strftime('%Y-%m', stars.starred_at),
        'timestamp_utc', datetime(stars.starred_at),
        'timestamp_unix', CAST(strftime('%s', stars.starred_at) AS INT),
        'repo_name', repos.full_name,
        'repo_description', repos.description,
        'repo_homepage', repos.homepage,
        'repo_license', repos.license,
        'repo_language', repos.language,
        'repo_stars_count', repos.stargazers_count
    ) AS json
FROM users
LEFT JOIN stars on stars.user = users.id
LEFT JOIN repos on stars.repo = repos.id
WHERE login='${USER}'
ORDER BY stars.starred_at ASC
"
