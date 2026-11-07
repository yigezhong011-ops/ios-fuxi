#!/bin/bash
set -uo pipefail
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')

echo "=== run 41645221755 详情 ==="
curl -fsSL "${H[@]}" 'https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs/41645221755' \
  | python3 -c 'import json,sys
d=json.load(sys.stdin)
print("status", d["status"], "conclusion", d["conclusion"], "created", d["created_at"], "updated", d["updated_at"])
print("attempt", d["run_attempt"], "event", d["event"])'

echo
echo "=== 账号 Actions 用量（可能需要权限） ==="
curl -sS "${H[@]}" 'https://api.github.com/users/yigezhong011-ops/settings/billing/actions' | head -c 400
echo
