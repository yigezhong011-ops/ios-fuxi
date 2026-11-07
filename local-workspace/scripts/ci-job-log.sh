#!/bin/bash
# Fetch the failing job's log with curl (urllib loses the auth header on redirect).
set -uo pipefail
T=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
REPO=yigezhong011-ops/ios-fuxi
RUN=$(curl -sL -H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/repos/$REPO/actions/runs?per_page=3" | \
  python3 -c 'import json,sys; rs=json.load(sys.stdin)["workflow_runs"]; print(next(r["id"] for r in rs if r["name"].startswith("UniXNU")))')
echo "run $RUN"
JOB=$(curl -sL -H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/repos/$REPO/actions/runs/$RUN/jobs" | \
  python3 -c 'import json,sys; print(json.load(sys.stdin)["jobs"][0]["id"])')
echo "job $JOB"
curl -sL -H "Authorization: Bearer $T" "https://api.github.com/repos/$REPO/actions/jobs/$JOB/logs" -o /root/ci-job.log
echo "日志 $(wc -l < /root/ci-job.log) 行"
echo "=== 失败步骤附近 ==="
grep -n 'Select the configuration' /root/ci-job.log | head -2
line=$(grep -n 'error\|Error\|fatal\|not found\|failed' /root/ci-job.log | head -3 | cut -d: -f1)
for l in $line; do sed -n "$((l-3)),$((l+3))p" /root/ci-job.log | cut -c1-200; echo "---"; done
