#!/usr/bin/env bash
# Imports photos and videos from Apple Photos
# including labels.

PHOTOS_DB_PATH=${PHOTOS_DB_PATH:=/Users/$(whoami)/Pictures/Photos\ Library.photoslibrary/database/Photos.sqlite}
PSI_DB_PATH=${PSI_DB_PATH:=/Users/$(whoami)/Pictures/Photos\ Library.photoslibrary/database/search/psi.sqlite}

sqlite3 -readonly "$PHOTOS_DB_PATH" "
-- Machine learning metadata information from psi.sqlite
-- The set UUID is split into two integers (uuid_0, uuid_1) and needs to be converted manually.
ATTACH DATABASE '$PSI_DB_PATH' as psi;
WITH metadata AS (
    SELECT
        substr(printf('%p', assets.uuid_0), 15, 2)
            || substr(printf('%p', assets.uuid_0), 13, 2)
            || substr(printf('%p', assets.uuid_0), 11, 2)
            || substr(printf('%p', assets.uuid_0), 9, 2)
            || '-'
            || substr(printf('%p', assets.uuid_0), 7, 2)
            || substr(printf('%p', assets.uuid_0), 5, 2)
            || '-'
            || substr(printf('%p', assets.uuid_0), 3, 2)
            || substr(printf('%p', assets.uuid_0), 1, 2)
            || '-'
            || substr(printf('%p', assets.uuid_1), 15, 2)
            || substr(printf('%p', assets.uuid_1), 13, 2)
            || '-'
            || substr(printf('%p', assets.uuid_1), 11, 2)
            || substr(printf('%p', assets.uuid_1), 9, 2)
            || substr(printf('%p', assets.uuid_1), 7, 2)
            || substr(printf('%p', assets.uuid_1), 5, 2)
            || substr(printf('%p', assets.uuid_1), 3, 2)
            || substr(printf('%p', assets.uuid_1), 1, 2)
        as uuid,
        assets.uuid_0,
        assets.uuid_1,
        json_group_array(substr(groups.content_string,1,instr(groups.content_string,char(0)))) as labels
    FROM
      psi.assets
      JOIN psi.ga ON assets.rowid = ga.assetid
      JOIN psi.groups ON ga.groupid = groups.rowid
          AND groups.category NOT IN (
              2058, -- file name
              2037, -- empty string
              2047  -- empty string
          )
    GROUP BY
      assets.rowid
)
SELECT
    json_object(
        'provider', 'Photos',
        'verb', 'photographed',
        'id', 'photos-' || ZASSET.ZUUID,
        'uuid', metadata.uuid,
        'date_month', strftime('%Y-%m', ZASSET.ZDATECREATED + strftime('%s', '2001-01-01'), 'unixepoch'),
        'timestamp_utc', datetime(ZASSET.ZDATECREATED + strftime('%s', '2001-01-01'), 'unixepoch'),
        'timestamp_unix', CAST(ZASSET.ZDATECREATED + strftime('%s', '2001-01-01') AS INT),
        'timezone_name', ZADDITIONALASSETATTRIBUTES.ZTIMEZONENAME,
        'photo_file_path', ZASSET.ZDIRECTORY || '/' || ZASSET.ZFILENAME,
        'photo_file_name', ZADDITIONALASSETATTRIBUTES.ZORIGINALFILENAME,
        'photo_kind', CASE ZASSET.ZKIND WHEN 0 THEN 'photo' ELSE 'movie' END,
        'photo_labels', json_extract(metadata.labels, '$'),
        'location_latitude', CASE WHEN ZASSET.ZLATITUDE == -180.0 AND ZASSET.ZLONGITUDE == -180.0 THEN NULL ELSE ZASSET.ZLATITUDE END,
        'location_longitude', CASE WHEN ZASSET.ZLATITUDE == -180.0 AND ZASSET.ZLONGITUDE == -180.0 THEN NULL ELSE ZASSET.ZLONGITUDE END,
        'device_name', ZEXTENDEDATTRIBUTES.ZCAMERAMAKE || ' ' || ZEXTENDEDATTRIBUTES.ZCAMERAMODEL
    ) AS json
FROM ZASSET
LEFT JOIN ZADDITIONALASSETATTRIBUTES ON ZASSET.ZADDITIONALATTRIBUTES=ZADDITIONALASSETATTRIBUTES.Z_PK
LEFT JOIN ZEXTENDEDATTRIBUTES ON ZEXTENDEDATTRIBUTES.ZASSET = ZASSET.Z_PK
JOIN metadata ON ZASSET.ZUUID=metadata.uuid
"
