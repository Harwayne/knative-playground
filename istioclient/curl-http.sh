#!/bin/bash

if [ -z "$channel" ]; then
  channel="default-broker.default.svc.cluster.local"
fi

if [ -z "$eventType" ]; then
  eventType="com.example.someevent"
fi

if [ -z "$eventSource" ]; then
  eventSource="/mycontext/subcontext"
fi

set -u

traceId=$(cat /proc/sys/kernel/random/uuid)
traceId="${traceId//-/}"

eventId=$(cat /proc/sys/kernel/random/uuid)

curl -v "http://$channel/" \
  -X POST \
  -H "X-B3-Traceid: $traceId" \
  -H "X-B3-Spanid: ${traceId:17:32}" \
  -H "X-B3-Flags: 1" \
  -H 'CE-CloudEventsVersion: "0.1"' \
  -H "CE-EventType: \"$eventType\"" \
  -H 'CE-EventTime: "2018-04-05T03:56:24Z"' \
  -H "CE-EventID: \"$eventId\"" \
  -H "CE-Source: \"$eventSource\"" \
  -H 'Content-Type: application/json' \
  -d '{ "much": "wow" }'

echo "Sent with eventID $eventId with traceID $traceId"

