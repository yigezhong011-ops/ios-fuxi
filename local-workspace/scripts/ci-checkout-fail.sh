#!/bin/bash
# Read only: the failing step's log of a unixnu-ci run. Usage: <run-id>
T=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt); R=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
H=(-H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json')
J=$(curl -fsSL "${H[@]}" "$R/actions/runs/$1/jobs" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["jobs"][0]["id"])')
curl -fsSL "${H[@]}" -L "$R/actions/jobs/$J/logs" -o /tmp/ci-job.log
grep -nE '##\[error\]|repository:|fatal:|Not Found|ref:' /tmp/ci-job.log | sed -E 's/^([0-9]+):[0-9TZ:.-]+ /\1 /' | cut -c1-150 | head -24
for u in ljhhkx529/unixnu-fuxi UniXNU/UniXNU; do echo "$u $(curl -s -o /dev/null -w '%{http_code}' https://github.com/$u)"; done
git ls-remote https://github.com/ljhhkx529/unixnu-fuxi.git 'refs/heads/old' 'refs/heads/V2' 2>&1 | cut -c1-70 | head -4
