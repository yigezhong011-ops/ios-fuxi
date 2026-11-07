#!/bin/bash
set -uo pipefail
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')

echo "=== 13:30Z 之后创建的 run（看是谁挤掉了它） ==="
curl -fsSL "${H[@]}" 'https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs?per_page=15' \
  | python3 -c 'import json,sys
for r in json.load(sys.stdin)["workflow_runs"]:
    if r["created_at"] >= "2026-11-03T13:30":
        print(r["id"], r["name"][:34], r["status"], r["conclusion"], r["created_at"])'

echo
echo "=== 我们 workflow 的 concurrency 设置 ==="
grep -n -A4 'concurrency' /mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml | head -12
echo
echo "=== timeout / cancel 相关 ==="
grep -nE 'timeout-minutes|cancel|fail-fast' /mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml | head -8
