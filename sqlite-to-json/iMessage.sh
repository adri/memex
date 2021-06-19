#!/usr/bin/env bash
CHAT_DB_PATH=${CHAT_DB_PATH:="${HOME}/Library/Messages/chat.db"}
CONTACTS_DB_PATH=${CONTACTS_DB_PATH:="AAE8D6A5-FEED-47BB-82CF-1A51C6789400/AddressBook-v22.abcddb"}
DATE_CORRECTION="/ 1000000000 + 978307200" # strftime('%s', '2001-01-01')

sqlite3 -readonly ${CHAT_DB_PATH} "
-- Contact information from Contacts.app
ATTACH DATABASE '${HOME}/Library/Application Support/AddressBook/Sources/${CONTACTS_DB_PATH}' as contacts;
WITH contact AS (
    SELECT
        record.ZUNIQUEID as id,
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
        'id', 'imessage-' || message.guid,
        'date_month', strftime('%Y-%m', message.date ${DATE_CORRECTION}, 'unixepoch'),
        'timestamp_utc', datetime(message.date ${DATE_CORRECTION}, 'unixepoch'),
        'timestamp_unix', CAST(strftime('%s', datetime(message.date ${DATE_CORRECTION}, 'unixepoch')) as INT),
        'message_direction', (CASE WHEN message.is_from_me THEN 'sent' ELSE 'received' END),
        'message_service', chat.service_name,
        'message_text', message.text,
        'person_name', CASE WHEN contact.first_name IS NULL AND contact.last_name IS NULL THEN chat.chat_identifier ELSE contact.first_name || ' ' || contact.last_name END,
        'person_id', contact.id
    ) AS json
FROM
    main.chat chat
    JOIN chat_message_join ON chat.ROWID = chat_message_join.chat_id
    JOIN message ON chat_message_join.message_id = message.ROWID
    LEFT JOIN contact ON contact.phone_number = chat.chat_identifier OR contact.email_address = chat.chat_identifier
WHERE
    message.text IS NOT NULL
GROUP BY
    message.guid
"
