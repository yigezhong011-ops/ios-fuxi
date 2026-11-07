#!/bin/bash
# Cancel the run that started with default inputs, then dispatch with build_kernel=false.
set -uo pipefail
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
R=yigezhong011-ops/unixnu-ci
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' -H 'Content-Type: application/json')

echo "=== 当前 run 的输入 ==="
curl -fsSL "${H[@]}" "https://api.github.com/repos/$R/actions/runs/41595221527" \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["status"], d["conclusion"]); print("inputs:", d.get("inputs"))'

echo "=== 取消 ==="
curl -fsSL -X POST "${H[@]}" "https://api.github.com/repos/$R/actions/runs/41595221527/cancel" | head -c 200
echo
sleep 8

echo "=== 重新触发（只编插件） ==="
bash /root/fuxi/dcr.sh 793d6bddf7 false 2>&1 | tail -4
