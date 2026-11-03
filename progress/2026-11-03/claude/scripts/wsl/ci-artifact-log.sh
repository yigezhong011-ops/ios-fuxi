#!/bin/bash
# Download a run's fuxi-gpu-logs artifact and print the first errors of one build log. Usage: <run-id> <log-name-substring>
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
R=yigezhong011-ops/unixnu-ci
U=$(curl -fsSL -H "Authorization: Bearer $TOKEN" "https://api.github.com/repos/$R/actions/runs/$1/artifacts" | python3 -c 'import json,sys; print([a["archive_download_url"] for a in json.load(sys.stdin)["artifacts"] if a["name"]=="fuxi-gpu-logs"][0])')
D=/root/fuxi/ci-logs-$1; rm -rf $D; mkdir -p $D
curl -fsSL -L -H "Authorization: Bearer $TOKEN" "$U" -o $D/l.zip && unzip -q -o $D/l.zip -d $D
F=$(find $D -name "*$2*" | head -1); echo "log: $F"
grep -n -m 12 'error:' "$F" | cut -c1-260
