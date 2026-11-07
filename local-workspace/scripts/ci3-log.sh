#!/bin/bash
# Fetch the latest UniXNU fork job log and show the failing part.
set -uo pipefail
T=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
REPO=yigezhong011-ops/UniXNU
RUN=$(curl -sL -H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/repos/$REPO/actions/runs?per_page=1" | \
  python3 -c 'import json,sys; print(json.load(sys.stdin)["workflow_runs"][0]["id"])')
JOB=$(curl -sL -H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/repos/$REPO/actions/runs/$RUN/jobs" | \
  python3 -c 'import json,sys; print(json.load(sys.stdin)["jobs"][0]["id"])')
curl -sL -H "Authorization: Bearer $T" "https://api.github.com/repos/$REPO/actions/jobs/$JOB/logs" -o /root/ci3.log
echo "run $RUN  job $JOB  日志 $(wc -l < /root/ci3.log) 行"
echo "=== 错误行 ==="
grep -n 'error:\|Error:\|##\[error\]\|fatal error' /root/ci3.log | head -10 | cut -c1-220
echo
echo "=== 最后 30 行 ==="
tail -30 /root/ci3.log | cut -c1-200
