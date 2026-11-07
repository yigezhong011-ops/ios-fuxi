#!/bin/bash
# Read only: the errors of a failed GPU addon step. Usage: <run-id>
T=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt); R=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
H=(-H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json')
J=$(curl -fsSL "${H[@]}" "$R/actions/runs/$1/jobs" | python3 -I -c 'import json,sys
j=json.load(sys.stdin)["jobs"][0]; print(j["id"])
for x in j["steps"]: print(x["name"], x["conclusion"], x["started_at"], x["completed_at"], file=sys.stderr)')
curl -fsSL "${H[@]}" -L "$R/actions/jobs/$J/logs" -o /tmp/ci-job.log
wc -l /tmp/ci-job.log
sed -E 's/^[0-9TZ:.-]+ //' /tmp/ci-job.log > /tmp/ci-job.txt
grep -n 'SKIPPED' /tmp/ci-job.txt | cut -c1-100 | head
L=$(grep -n '##\[error\]' /tmp/ci-job.txt | head -1 | cut -d: -f1)
echo "first error line $L"
sed -n "$((L-45)),$((L+4))p" /tmp/ci-job.txt | cut -c1-170
