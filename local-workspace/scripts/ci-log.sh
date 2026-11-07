#!/bin/bash
# Failing step's tail of a unixnu-ci run. Usage: ci-log.sh <run-id>
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')
J=$(curl -fsSL "${H[@]}" "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs/$1/jobs" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["jobs"][0]["id"])')
bash /root/fuxi/crst.sh "$1" | cut -c1-90 | grep -v -E 'pending|Post' | tail -8
curl -fsSL -L "${H[@]}" "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/jobs/$J/logs" -o /root/fuxi/ci-$1.log
wc -l /root/fuxi/ci-$1.log
grep -n -E 'error:|error\[|Error:|##\[error\]|FAILED|fatal:' /root/fuxi/ci-$1.log | cut -c30-260 | head -30
