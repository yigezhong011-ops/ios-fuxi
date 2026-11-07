#!/bin/bash
# Third try: drop the include of a file our pin lacks, check every include the port adds, and dispatch. Normal push; token in a header only.
set -uo pipefail
E=/mnt/e/DSH-Fuxi
cd /root/fuxi/plugin-try
sed -i '/#include "SharedShaderCache.h"/d' NativeBridgeMetalFrontend.mm
git add -A; git -c user.name=fuxi -c user.email=fuxi@example.invalid commit -q -m "frontend: drop the include of 69efcdc's header"
echo "== includes the port adds"
git diff 7e0d3d2 HEAD -- '*.mm' '*.h' ':!bridge/patches' | grep -E '^\+ *#(include|import)' | cut -c1-90
echo "== quoted includes in the frontend that do not exist"
grep -o -E '#(include|import) "[^"]+"' NativeBridgeMetalFrontend.mm CacheExport.h | sed -E 's/.*"(.*)"/\1/' | sort -u | while read -r f; do [ -f "$f" ] || [ -f "bridge/$f" ] || echo "  missing: $f"; done
git diff 7e0d3d2 HEAD -- CacheExport.h | cut -c1-120
git diff 7e0d3d2 HEAD > /root/fuxi/plugin-poster.patch; wc -l /root/fuxi/plugin-poster.patch
set -e
TOKEN=$(tr -d '\r\n ' < $E/token2.txt)
AUTH="AUTHORIZATION: basic $(printf 'x-access-token:%s' "$TOKEN" | base64 -w0)"
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')
curl -fsSL "${H[@]}" https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs/41940578538 | python3 -I -c 'import json,sys; r=json.load(sys.stdin); print("old run", r["status"], r["conclusion"])'
G=/root/fuxi/unixnu-ci-push; rm -rf $G
git -c http.extraheader="$AUTH" clone -q --depth 5 https://github.com/yigezhong011-ops/unixnu-ci.git $G
cd $G
cp /root/fuxi/plugin-poster.patch ci/patches/adrenometal-poster-7e0d3d2.patch
if grep -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED' ci/patches/adrenometal-poster-7e0d3d2.patch; then echo secret; exit 1; fi
git add -A; git diff --cached --stat | tail -2 | cut -c1-90
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "ci: plugin patch without the shared shader cache of 69efcdc

8c1ea13 calls two helpers from 69efcdc, which our pin lacks and this work does not need."
git -c http.extraheader="$AUTH" push -q origin HEAD:main
curl -fsSL -X POST "${H[@]}" https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/workflows/fuxi-gpu.yml/dispatches -d '{"ref":"main","inputs":{"unixnu_ref":"793d6bddf7ea90678e3a61e2b2bd4350e5fdce16","build_kernel":"false","plugin_patch":"adrenometal-poster-7e0d3d2.patch"}}' && echo dispatched
sleep 12
curl -fsSL "${H[@]}" 'https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/workflows/fuxi-gpu.yml/runs?per_page=1' | python3 -I -c 'import json,sys; r=json.load(sys.stdin)["workflow_runs"][0]; print(r["id"], r["status"], r["head_sha"][:7], r["created_at"])'
