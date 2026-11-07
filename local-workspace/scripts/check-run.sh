#!/bin/bash
set -uo pipefail
RUN=${1:-41747200375}
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs/$RUN/jobs" \
  | python3 -c 'import json,sys
j=json.load(sys.stdin)["jobs"][0]
print("job", j["status"], j["conclusion"], "runner", j.get("runner_name"), "started", j.get("started_at"))
for s in j["steps"]:
    print("  %-24s %-10s %-9s start=%s" % (s["name"], s["status"], s["conclusion"], s.get("started_at")))'
echo "--- 自动化日志 ---"
tail -5 /root/fuxi/deepseek-gpu.log
