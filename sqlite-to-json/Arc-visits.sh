#!/usr/bin/env bash
# Imports visits of places from Arc app exports

ARC_PATH=${ARC_PATH:=/Users/$(whoami)/Library/Mobile\ Documents/iCloud~com~bigpaua~LearnerCoacher/Documents/Export/JSON/Monthly}

# Load Foursquare categories when credentials are set
# FOURSQUARE_VENUE_CATEGORIES_CACHE="./data/foursquare-venue-categories.json"
# if [ -n "$FOURSQUARE_CLIENT_ID" ]; then
#     if [ ! -f "$FOURSQUARE_VENUE_CATEGORIES_CACHE" ]; then
#       curl -s -o "$FOURSQUARE_VENUE_CATEGORIES_CACHE" "https://api.foursquare.com/v2/venues/categories?client_id=$FOURSQUARE_CLIENT_ID&client_secret=$FOURSQUARE_CLIENT_SECRET&v=20210501"
#     fi

#     if [ -f "$FOURSQUARE_VENUE_CATEGORIES_CACHE" ]; then
#       cat "$FOURSQUARE_VENUE_CATEGORIES_CACHE" | jq '.response.categories[] | {id, name}'
#     fi
# fi

find "$ARC_PATH" -name '*.json.gz' -print0 \
| xargs -0 gzip -dc \
| TZ=Etc/UTC jq --raw-output -c '
  .timelineItems[]
  | select(.isVisit == true)
  | {
    "id": ("arc-" + .itemId),
    "id_next": ("arc-" + .nextItemId),
    "id_previous": ("arc-" + .previousItemId),
    "verb": "visited",
    "provider": "Arc",
    "date_month": .endDate | fromdate | strftime("%Y-%m"),
    "timestamp_unix": .endDate | fromdate,
    "timestamp_utc": .endDate,
    "timestamp_start_unix": .startDate | fromdate,
    "timestamp_start_utc": .startDate,
    "place_name": .place.name,
    "place_address": .streetAddress,
    "place_latitude": .center.latitude,
    "place_longitude": .center.longitude,
    "place_altitude": .altitude,
    "place_foursquare_venue_id": .place.foursquareVenueId,
    "activity_step_count": .stepCount,
    "activity_floors_ascended": .floorsAscended,
    "activity_floors_descended": .floorsDescended,
    "activity_heart_rate_average": .averageHeartRate,
    "activity_heart_rate_max": .maxHeartRate,
    "activity_active_energy_burned": .activeEnergyBurned,
    }
  '  \
  | jq -s -c '. | unique_by(.id) | .[]'