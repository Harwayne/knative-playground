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

if [ "$quote" = "none" ]; then
  quote=""
else
  quote="\""
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
  -H "CE-CloudEventsVersion: ${quote}0.1${quote}" \
  -H "CE-EventType: ${quote}${eventType}${quote}" \
  -H "CE-EventTime: ${quote}2018-04-05T03:56:24Z${quote}" \
  -H "CE-EventID: ${quote}${eventId}${quote}" \
  -H "CE-Source: ${quote}${eventSource}${quote}" \
  -H 'Content-Type: application/json' \
  -d '{ "much": "wow" }'

echo "Sent with eventID $eventId with traceID $traceId"

