#!/bin/bash

vars="export channel=$channel; export eventType=$eventType; export eventSource=$eventSource"
cmd="${vars}; /curl-http.sh;"

echo "$cmd"

kubectl exec -it istioclient -- /bin/bash -c "$cmd"

