#!/bin/bash
# Plugin-only build of upstream's feat/metal2vulkan-963f0e64 on the owner's unixnu-ci. No commit; a workflow dispatch only. Token in a header only.
set -euo pipefail
E=/mnt/e/DSH-Fuxi; T=$(tr -d '\r\n ' < $E/token2.txt)
H=(-H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json')
R=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
SHA=$(git -C /root/fuxi/up-latest rev-parse origin/feat/metal2vulkan-963f0e64)
echo "unixnu_ref $SHA"
curl -fsSL "${H[@]}" -H 'Accept: application/vnd.github.raw' "$R/contents/.github/workflows/fuxi-gpu.yml" > /tmp/fuxi-gpu-remote.yml
sed -n '/workflow_dispatch/,/^permissions/p' /tmp/fuxi-gpu-remote.yml | grep -E '^      [a-z_]+:|default:' | cut -c1-70
sed -n 195,250p /tmp/fuxi-gpu-remote.yml | cut -c1-120 | grep -nE 'build_plugin|checkout\(|build-adreno|patch' | head -20
curl -fsSL "${H[@]}" "$R/actions/workflows/fuxi-gpu.yml/runs?per_page=4" | python3 -I -c 'import json,sys
for r in json.load(sys.stdin)["workflow_runs"]: print(r["id"], r["status"], r["conclusion"], r["created_at"], r["display_title"][:40])'
curl -fsSL -X POST "${H[@]}" "$R/actions/workflows/fuxi-gpu.yml/dispatches" -d "{\"ref\":\"main\",\"inputs\":{\"unixnu_ref\":\"$SHA\",\"build_kernel\":\"false\"}}"
echo dispatched; sleep 12
curl -fsSL "${H[@]}" "$R/actions/workflows/fuxi-gpu.yml/runs?per_page=1" | python3 -I -c 'import json,sys; r=json.load(sys.stdin)["workflow_runs"][0]; print(r["id"], r["status"], r["head_sha"][:7], r["created_at"])'
