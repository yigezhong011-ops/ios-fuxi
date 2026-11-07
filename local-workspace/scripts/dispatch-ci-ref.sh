#!/bin/bash
# Dispatch fuxi-gpu.yml with a pinned UniXNU revision. Usage: dispatch-ci-ref.sh <unixnu short or full sha>
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')
FULL=$(curl -fsSL "${H[@]}" "https://api.github.com/repos/UniXNU/UniXNU/commits/$1" | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])')
echo "UniXNU $FULL"
curl -fsSL -X POST "${H[@]}" "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/workflows/fuxi-gpu.yml/dispatches" \
  -d "{\"ref\":\"main\",\"inputs\":{\"unixnu_ref\":\"$FULL\",\"build_kernel\":\"${2:-true}\"}}" && echo dispatched
sleep 8
curl -fsSL "${H[@]}" "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/workflows/fuxi-gpu.yml/runs?per_page=1" | python3 -c 'import json,sys; r=json.load(sys.stdin)["workflow_runs"][0]; print(r["id"], r["status"], r["html_url"])'
