#!/bin/bash
# Step status of a unixnu-ci run. Usage: ci-run-status.sh <run-id>
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs/$1/jobs" | python3 -c '
import json, sys
j = json.load(sys.stdin)["jobs"][0]
print(j["status"], j["conclusion"])
for s in j["steps"]:
    print(" ", s["number"], s["name"], s["status"], s["conclusion"], (s["started_at"] or "")[11:19], (s["completed_at"] or "")[11:19])
'
