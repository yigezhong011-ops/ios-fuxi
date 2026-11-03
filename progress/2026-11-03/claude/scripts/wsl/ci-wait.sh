#!/bin/bash
# Wait for a unixnu-ci run to finish (check every 2 min, at most 3 h), then print its step status.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
for i in $(seq 1 90); do
  s=$(curl -fsSL -H "Authorization: Bearer $TOKEN" "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs/$1" | python3 -c 'import json,sys; print(json.load(sys.stdin)["status"])')
  [ "$s" = completed ] && break
  sleep 120
done
bash /root/fuxi/crst.sh "$1"
