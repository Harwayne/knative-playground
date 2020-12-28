#!/bin/bash

if [ -z "$channel" ]; then
  channel="default-broker.default.svc.cluster.local"
fi

if [ -z "$uri" ]; then
  uri="http://$channel"
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

curl -v "$uri" \
  -X POST \
  -H "X-B3-Traceid: ${traceId}" \
  -H "X-B3-Spanid: ${traceId:16}" \
  -H "X-B3-Flags: 1" \
  -H "ce-specversion: 1.0" \
  -H "ce-type: ${eventType}" \
  -H "ce-time: 2018-04-05T03:56:24Z" \
  -H "ce-id: ${eventId}" \
  -H "ce-source: ${eventSource}" \
  -H 'Content-Type: application/json' \
  -d '{ "much": "wow" }'

echo "Sent with eventID $eventId with traceID $traceId"

