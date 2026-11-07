#!/bin/bash
# Cancel the doomed run, then read where the two helpers come from and what depends on them.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
curl -fsSL -X POST -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs/41940578538/cancel && echo cancel-sent
cd /root/fuxi/src-adrenometal
for s in configureShaderDiskCache sharedShaderCacheDirectory; do echo "== $s"; git log --format='%h %s' -S"$s" 7e0d3d2..8c1ea13 -- NativeBridgeMetalFrontend.mm | cut -c1-90; done
git show --stat --format='%h %s' 69efcdc | cut -c1-90
git show 69efcdc -- NativeBridgeMetalFrontend.mm | cut -c1-170 | head -70
cd /root/fuxi/plugin-try
sed -n 578,592p NativeBridgeMetalFrontend.mm | cut -c1-170
echo "== pin"; git show 7e0d3d2:NativeBridgeMetalFrontend.mm | grep -n -E 'NSCachesDirectory' | cut -c1-170
