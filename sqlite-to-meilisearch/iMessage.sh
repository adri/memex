sqlite3 -readonly ~/Library/Messages/chat.db "
-- Contact information from Contacts.app
ATTACH DATABASE '/Users/adrimbp/Library/Application Support/AddressBook/Sources/14628275-DA9B-4559-8D40-8E98D59B14CD/AddressBook-v22.abcddb' as contacts;
WITH contact AS (
    SELECT
        record.ZFIRSTNAME AS first_name,
        record.ZLASTNAME AS last_name,
        REPLACE(phone.ZFULLNUMBER, ' ', '') AS phone_number,
        email.ZADDRESSNORMALIZED AS email_address
    FROM
        contacts.ZABCDRECORD AS record
    LEFT JOIN contacts.ZABCDPHONENUMBER AS phone ON phone.ZOWNER = record.Z_PK
    LEFT JOIN contacts.ZABCDEMAILADDRESS AS email ON email.ZOWNER = record.Z_PK
)
SELECT
    json_object(
        'provider', 'iMessage',
        'verb', 'messaged',
        'id', message.guid,
        'date_month', strftime('%Y-%m', message.date / 1000000000 + strftime ('%s', '2001-01-01'), 'unixepoch', 'utc'),
        'timestamp_utc', datetime(message.date / 1000000000 + strftime('%s', '2001-01-01'), 'unixepoch', 'utc'),
        'timestamp_unix', strftime('%s', datetime(message.date / 1000000000 + strftime('%s', '2001-01-01'), 'unixepoch', 'utc')),
        'message_direction', (CASE WHEN message.is_from_me THEN 'sent' ELSE 'received' END),
        'message_service', chat.service_name,
        'message_text', message.text,
        'person_name', contact.first_name || ' ' || contact.last_name
	) AS json
FROM
    main.chat chat
    JOIN chat_message_join ON chat.ROWID = chat_message_join.chat_id
    JOIN message ON chat_message_join.message_id = message.ROWID
    LEFT JOIN contact ON contact.phone_number = chat.chat_identifier OR contact.email_address = chat.chat_identifier
ORDER BY
    message_date ASC
"
