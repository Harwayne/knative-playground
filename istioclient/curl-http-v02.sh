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

if [ "$quote" = "quote" ]; then
  quote="\""
else
  quote=""
fi

set -u

traceId=$(cat /proc/sys/kernel/random/uuid)
traceId="${traceId//-/}"

eventId=$(cat /proc/sys/kernel/random/uuid)

curl -v "http://$channel/" \
  -X POST \
  -H "X-B3-Traceid: ${traceId}" \
  -H "X-B3-Spanid: ${traceId:16}" \
  -H "X-B3-Flags: 1" \
  -H "ce-specversion: ${quote}0.2${quote}" \
  -H "ce-type: ${quote}${eventType}${quote}" \
  -H "ce-time: ${quote}2018-04-05T03:56:24Z${quote}" \
  -H "ce-id: ${quote}${eventId}${quote}" \
  -H "ce-source: ${quote}${eventSource}${quote}" \
  -H 'Content-Type: application/json' \
  -d '{ "much": "wow" }'

echo "Sent with eventID $eventId with traceID $traceId"

