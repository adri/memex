#!/usr/bin/env bash
# Imports activities from Arc app exports

ARC_PATH=${ARC_PATH:=/Users/$(whoami)/Library/Mobile\ Documents/iCloud~com~bigpaua~LearnerCoacher/Documents/Export/JSON/Monthly}

find "$ARC_PATH" -name '*.json.gz' -print0 \
| xargs -0 gzip -dc \
| TZ=Etc/UTC jq --raw-output -c '
  .timelineItems[]
  | select(.isVisit == false and .uncertainActivityType == false)
  | {
    "id": ("arc-" + .itemId),
    "id_next": ("arc-" + .nextItemId),
    "id_previous": ("arc-" + .previousItemId),
    "verb": "moved",
    "provider": "Arc",
    "date_month": .endDate | fromdate | strftime("%Y-%m"),
    "timestamp_unix": .endDate | fromdate,
    "timestamp_utc": .endDate,
    "timestamp_start_unix": .startDate | fromdate,
    "timestamp_start_utc": .startDate,
    "activity_type": .activityType,
    "activity_step_count": .stepCount,
    "activity_floors_ascended": .floorsAscended,
    "activity_floors_descended": .floorsDescended,
    "activity_heart_rate_average": .averageHeartRate,
    "activity_heart_rate_max": .maxHeartRate,
    "activity_active_energy_burned": .activeEnergyBurned,
    }
  ' \
  | jq -s -c '. | unique_by(.id) | .[]'