#!/bin/bash

vars=""
vars+="export uri=$uri; "
vars+="export channel=$channel; "
vars+="export eventType=$eventType; "
vars+="export eventSource=$eventSource; "
vars+="export quote=$quote; "
cmd="${vars} /curl-http-v1.sh;"

echo "$cmd"

kubectl exec -it nosidecar -- /bin/bash -c "$cmd"

