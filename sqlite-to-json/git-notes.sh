#!/usr/bin/env bash
# Imports commits from local git notes repository
# Every commit is a change to my notes.

GIT_REPO_PATH=./data/notes
cd $GIT_REPO_PATH

# Update to the latest version
git fetch -q && git reset -q --hard origin/master

# Limit commits to avoid initial commits: e.g. -n5
git log -n6 --pretty=format:'<-SNIP->%H-;-%at-;-%B-;-' \
  --patch \
  --no-color \
  --no-ext-diff \
  --unified=0 \
  | sed '0,/^<-SNIP->/s///' \
  | jq --slurp --raw-input --raw-output \
    'split("<-SNIP->")
        | map(split("-;-"))
        | map(select(.[0] != null))
        | map({"id": ("git-" + .[0]),
             "verb": "committed",
             "provider": "git-notes",
             "timestamp_unix": .[1] | tonumber,
             "timestamp_utc": .[1] | tonumber | strftime("%Y-%m-%d %H:%M:%S"),
             "date_month": .[1] | tonumber | strftime("%Y-%m"),
             "commit_sha": .[0],
             "commit_diff": .[3] | gsub("\\\n\\\\ No newline at end of file"; "")
             })' \
   | jq -r '.[]'


# Alternative version using askgit, doens't work because it does not import
# the actual diff/patch. Maybe it's still useful to export other repositories.
# askgit --format json "
#   SELECT
#     'git' as provider,
#     'committed' as verb,
#     commits.message as commit_message,
#     json_group_array(
#         json_object(
#             'file', stats.file,
#             'additions', stats.additions,
#             'deletions', stats.deletions
#         )
#     ) as commit_files
#   FROM
#     commits
#   LEFT JOIN stats ON commits.id = stats.commit_id
#   GROUP BY commits.id
#   "