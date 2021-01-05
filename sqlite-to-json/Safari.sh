#!/usr/bin/env bash
# Imports browser history from Safari

HISTORY_DB_PATH=${HISTORY_DB_PATH:=~/Library/Safari/History.db}

sqlite3 $HISTORY_DB_PATH -readonly "
SELECT
    json_object(
        'provider', 'Safari',
        'verb', 'browsed',
        'id', 'safari-' || history_visits.id,
        'date_month', strftime('%Y-%m', history_visits.visit_time + 978307200, 'unixepoch', 'utc'),
        'timestamp_utc', datetime(history_visits.visit_time + 978307200, 'unixepoch', 'utc'),
        'timestamp_unix', CAST(strftime('%s', datetime(history_visits.visit_time + 978307200, 'unixepoch', 'utc')) AS INT),
        'website_title', history_visits.title,
        'website_url', history_items.URL,
        'device_name', (CASE origin WHEN 1 THEN 'iPhone 11 Pro' WHEN 0 THEN 'MacBook Pro' END)
    )
FROM
    history_visits
    INNER JOIN history_items ON history_items.id = history_visits.history_item
GROUP BY
    history_visits.id
"
