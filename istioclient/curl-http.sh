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

UUID=$(cat /proc/sys/kernel/random/uuid)

curl -v "http://$channel/" -X POST \
  -H 'Content-Type: application/json' \
  -H 'CE-CloudEventsVersion: "0.1"' \
  -H "CE-EventType: \"$eventType\"" \
  -H 'CE-EventTime: "2018-04-05T03:56:24Z"' \
  -H "CE-EventID: \"$UUID\"" \
  -H "CE-Source: \"$eventSource\"" \
  -d '{ "much": "wow" }'


echo "Sent with eventID $UUID"

