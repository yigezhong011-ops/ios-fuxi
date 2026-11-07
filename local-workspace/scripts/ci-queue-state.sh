#!/bin/bash
set -uo pipefail
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
echo "=== fuxi-gpu 相关 run 的当前状态 ==="
curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' \
  'https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs?per_page=10' \
  | python3 -c 'import json,sys
for r in json.load(sys.stdin)["workflow_runs"]:
    print("%-14s %-10s %-9s %s %s" % (r["id"], r["status"], r["conclusion"], r["created_at"], r["name"][:40]))'
echo
echo "=== 队列里还有什么在跑 ==="
curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' \
  'https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs?status=in_progress&per_page=5' \
  | python3 -c 'import json,sys
d=json.load(sys.stdin)["workflow_runs"]
print(len(d), "in progress")
for r in d: print(" ", r["id"], r["name"], r["created_at"])'
