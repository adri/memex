sqlite3 ~/Library/Safari/History.db -readonly "
SELECT
    json_object(
        'provider', 'Safari',
        'verb', 'browsed',
        'id', history_visits.id,
        'date_month', strftime('%Y-%m', history_visits.visit_time + 978307200, 'unixepoch', 'utc'),
        'timestamp_utc', datetime(history_visits.visit_time + 978307200, 'unixepoch', 'utc'),
        'timestamp_unix', strftime('%s', datetime(history_visits.visit_time + 978307200, 'unixepoch', 'utc')),
        'website_title', history_visits.title,
        'website_url', history_items.URL,
        'device_name', (CASE origin WHEN 1 THEN 'iPhone 11 Pro' WHEN 0 THEN 'MacBook Pro' END)
    )
FROM
    history_visits
    INNER JOIN history_items ON history_items.id = history_visits.history_item
    LEFT JOIN history_items_to_tags ON history_items.id = history_items_to_tags.history_item
    LEFT JOIN history_tags ON history_tags.id = history_items_to_tags.tag_id
GROUP BY
    history_visits.id
"
