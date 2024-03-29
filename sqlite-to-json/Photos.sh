#!/usr/bin/env bash
# Imports photos and videos from Apple Photos
# including labels.

PHOTOS_DB_PATH=${PHOTOS_DB_PATH:=/Users/$(whoami)/Pictures/Photos\ Library.photoslibrary/database/Photos.sqlite}
PSI_DB_PATH=${PSI_DB_PATH:=/Users/$(whoami)/Pictures/Photos\ Library.photoslibrary/database/search/psi.sqlite}

# Categories
# 1 to 12: various parts of the reverse geolocation data (1 is areas of interest and 12 is country)
# 1: area of interest
# 2: street
# 3: appears to be additional city-level/neighborhood info but not sure how this maps into other place data < city
# 5: additional city-level info < city
# 6: city
# 7: county? > city
# 9: sub-administrative area
# 10: state/administrative area name
# 11: state/administrative area abbreviation
# 12: country
# 1014: creation month
# 1015: creation year
# 2016: keyword
# 2017: title
# 2018: description
# 2021: person in image
# 2024: label from ML process
# 2027: meal (e.g. dining, lunch)
# 2029: holiday?
# 2030: season
# 2037: Group of people in image
# 2044: videos
# 2046: live photos
# 2049: time-lapse
# 2053: portrait
# 2054: selfies
# 2055: favorites

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
        json_group_array(substr(groups.content_string,1,instr(groups.content_string,char(0)))) as labels,
        json_group_array(substr(places.content_string,1,instr(places.content_string,char(0)))) as place_name
    FROM
        psi.assets
        JOIN psi.ga ON assets.rowid = ga.assetid
        JOIN psi.groups ON ga.groupid = groups.rowid
            AND groups.category NOT IN (
                2058, -- file name
                2037, -- empty string
                2047, -- empty string
                2021 -- people, this is imported via ZPERSON
            )
        LEFT JOIN groups people ON ga.groupid = people.rowid
		  AND people.category=2021
        LEFT JOIN groups places ON ga.groupid = places.rowid
		  AND places.category=5
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
        'place_name', json_extract(metadata.place_name, '$'),
        'person_id', json_group_array(ZPERSON.ZPERSONURI),
        'person_name', json_group_array(ZPERSON.ZFULLNAME),
        'location_latitude', CASE WHEN ZASSET.ZLATITUDE == -180.0 AND ZASSET.ZLONGITUDE == -180.0 THEN NULL ELSE ZASSET.ZLATITUDE END,
        'location_longitude', CASE WHEN ZASSET.ZLATITUDE == -180.0 AND ZASSET.ZLONGITUDE == -180.0 THEN NULL ELSE ZASSET.ZLONGITUDE END,
        'device_name', ZEXTENDEDATTRIBUTES.ZCAMERAMAKE || ' ' || ZEXTENDEDATTRIBUTES.ZCAMERAMODEL
    ) AS json
FROM ZASSET
LEFT JOIN ZADDITIONALASSETATTRIBUTES ON ZASSET.ZADDITIONALATTRIBUTES = ZADDITIONALASSETATTRIBUTES.Z_PK
LEFT JOIN ZEXTENDEDATTRIBUTES ON ZEXTENDEDATTRIBUTES.ZASSET = ZASSET.Z_PK
LEFT JOIN ZDETECTEDFACE ON ZDETECTEDFACE.ZASSET = ZASSET.Z_PK
LEFT JOIN ZPERSON ON ZDETECTEDFACE.ZPERSON = ZPERSON.Z_PK
JOIN metadata ON ZASSET.ZUUID=metadata.uuid
GROUP BY ZASSET.Z_PK
" \
| jq -s -c '. | map(. + {
    place_name: .place_name | map(select(. != null)),
    person_name: .person_name | map(select(. != "" and . != null)),
    person_id: .person_id | map(select(. != null)),
})' \
| jq -c -r '.[]'
