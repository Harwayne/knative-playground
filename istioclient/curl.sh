#!/bin/bash

set -u

UUID=$(cat /proc/sys/kernel/random/uuid)

CLOUD_EVENT_UNFILLED='{
    "cloudEventsVersion" : "0.1",
    "eventType" : "com.example.someevent",
    "eventTypeVersion" : "1.0",
    "source" : "/mycontext",
    "eventTime" : "2018-04-05T17:31:00Z",
    "extensions" : {
      "comExampleExtension" : "value"
    },
    "contentType" : "text/xml",
    "data" : "<much wow=\"xml\"/>"
    "eventID": "REPLACE_WITH_EVENT_ID",
}'

CLOUD_EVENT=$(echo "$CLOUD_EVENT_UNFILLED" | sed "s/REPLACE_WITH_EVENT_ID/$UUID/g")

curl -v "http://$channel/" -X POST -H 'Content-Type: application/json' -d "$CLOUD_EVENT"

echo "Sent with eventID $UUID"

