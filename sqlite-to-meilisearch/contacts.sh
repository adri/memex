sqlite3 "/Users/adrimbp/Library/Application Support/AddressBook/Sources/14628275-DA9B-4559-8D40-8E98D59B14CD/AddressBook-v22.abcddb" -readonly "
SELECT
    json_object(
    'id', history_visits.id,
    'time_utc', datetime (history_visits.visit_time + 978307200,
            'unixepoch',
            'localtime'),
    'website_title', history_visits.title,
    'website_url', history_items.URL,
    'website_tags', json_group_array (history_tags.title),
    'device', CASE origin
    WHEN 1 THEN
        'iPhone 11 Pro'
    WHEN 0 THEN
        'MacBook Pro'
    END
    ) || ','
FROM
    history_visits
    INNER JOIN history_items ON history_items.id = history_visits.history_item
    LEFT JOIN history_items_to_tags ON history_items.id = history_items_to_tags.history_item
    LEFT JOIN history_tags ON history_tags.id = history_items_to_tags.tag_id
GROUP BY
    history_visits.id
ORDER BY
    visit_time DESC
"
