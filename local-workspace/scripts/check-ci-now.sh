#!/bin/bash
set -uo pipefail
echo "=== run 41608354328 ==="
bash /root/fuxi/crst.sh 41608354328 2>&1 | head -12
echo
echo "=== 最近的 run ==="
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' \
  'https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs?per_page=6' \
  | python3 -c 'import json,sys
for r in json.load(sys.stdin)["workflow_runs"]:
    print(r["id"], r["status"], r["conclusion"], r["created_at"], r["head_sha"][:8])'
