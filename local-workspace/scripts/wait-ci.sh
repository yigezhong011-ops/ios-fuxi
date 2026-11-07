#!/bin/bash
# Waits for one unixnu-ci run to finish and prints its conclusion and failed steps. Usage: wait-ci.sh <run-id>
T=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt); R=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
H=(-H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json')
for i in $(seq 1 120); do
  s=$(curl -fsSL "${H[@]}" "$R/actions/runs/$1" | python3 -I -c 'import json,sys; r=json.load(sys.stdin); print(r["status"], r["conclusion"])')
  case "$s" in completed*) break;; esac
  sleep 60
done
echo "$1 $s"
curl -fsSL "${H[@]}" "$R/actions/runs/$1/jobs" | python3 -I -c 'import json,sys
for j in json.load(sys.stdin)["jobs"]:
  for x in j["steps"]:
    if x["conclusion"] not in ("success","skipped"): print(x["name"], x["conclusion"])'
