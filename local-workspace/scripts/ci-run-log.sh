#!/bin/bash
# Errors and the tail of a failed step from a unixnu-ci run's job log. Usage: ci-run-log.sh <run-id> [step-name]
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
R=yigezhong011-ops/unixnu-ci
JOB=$(curl -fsSL -H "Authorization: Bearer $TOKEN" "https://api.github.com/repos/$R/actions/runs/$1/jobs" | python3 -c 'import json,sys; print(json.load(sys.stdin)["jobs"][0]["id"])')
curl -fsSL -H "Authorization: Bearer $TOKEN" "https://api.github.com/repos/$R/actions/jobs/$JOB/logs" -o /root/fuxi/ci-job.log
STEP=${2:-kernel}
S=$(grep -n "##\[group\]Run ./unixnu defconfig\|##\[group\]Run python3 - <<'PY'" /root/fuxi/ci-job.log | head -2 | tail -1 | cut -d: -f1)
[ "$STEP" = kernel ] && S=$(grep -n '##\[group\]Run ./unixnu defconfig' /root/fuxi/ci-job.log | head -1 | cut -d: -f1)
E=$(grep -n '##\[error\]' /root/fuxi/ci-job.log | head -1 | cut -d: -f1)
echo "step starts $S, first error $E"
sed -n "$((E-60)),$((E+2))p" /root/fuxi/ci-job.log | cut -c30-260
