#!/bin/bash
# Show why the forked macOS build failed.
set -uo pipefail
T=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
REPO=yigezhong011-ops/UniXNU
RUN=$(curl -sL -H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/repos/$REPO/actions/runs?per_page=3" | \
  python3 -c 'import json,sys; rs=json.load(sys.stdin)["workflow_runs"]; print(rs[0]["id"])')
echo "run $RUN"
JOB=$(curl -sL -H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/repos/$REPO/actions/runs/$RUN/jobs" | \
  python3 -c 'import json,sys; print(json.load(sys.stdin)["jobs"][0]["id"])')
curl -sL -H "Authorization: Bearer $T" "https://api.github.com/repos/$REPO/actions/jobs/$JOB/logs" -o /root/ci2.log
echo "日志 $(wc -l < /root/ci2.log) 行"
echo "=== 失败的步骤 ==="
grep -n '##\[error\]\|Error:\|error:' /root/ci2.log | head -8 | cut -c1-220
echo
echo "=== 最后 25 行 ==="
tail -25 /root/ci2.log | cut -c1-200
