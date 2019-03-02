#!/bin/bash

vars="export channel=$channel; "
vars+="export eventType=$eventType; "
vars+="export eventSource=$eventSource; "
vars+="export quote=$quote; "
cmd="${vars} /curl-http.sh;"

echo "$cmd"

kubectl exec -it istioclient -- /bin/bash -c "$cmd"

