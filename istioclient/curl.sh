#!/bin/bash

if [ -z "$channel" ]; then
  channel="default-broker.default.svc.cluster.local"
fi

set -u

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

traceId=$(cat /proc/sys/kernel/random/uuid)
traceId="${traceId//-/}"

eventId=$(cat /proc/sys/kernel/random/uuid)

curl -v "http://$channel/"  \
  -X POST \
  -H "X-B3-Traceid: $traceId" \
  -H "X-B3-Spanid: ${traceId:17:32}" \
  -H "X-B3-Flags: 1" \
  -H 'Content-Type: application/json' \
  -d "$CLOUD_EVENT"

echo "Sent with eventID $eventId with traceID $traceId"

