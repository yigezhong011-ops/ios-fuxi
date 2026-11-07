#!/bin/bash
# Read-only checks for the DeepSeek GPU script: workflow on GitHub vs disk, recent runs, the install path on the t50 volume.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
API=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
E=/mnt/e/DSH-Fuxi/dump/wsl
curl -s -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github.raw' "$API/contents/.github/workflows/fuxi-gpu.yml" > /tmp/wf.yml
echo "== workflow disk vs GitHub (lines differing)"
tr -d '\r' < /mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml | diff - /tmp/wf.yml | wc -l
echo "== recent runs"
curl -s -H "Authorization: Bearer $TOKEN" "$API/actions/runs?per_page=14" | python3 -c '
import json,sys
for r in json.load(sys.stdin)["workflow_runs"]:
    print(r["id"], r["head_sha"][:7], r["conclusion"], r["run_started_at"], r["updated_at"])'
for B in t50-mine t36-bl2; do
  echo "== $B"
  V=/root/fuxi/$B/vol.img; W=/tmp/dry-$B; rm -rf $W; mkdir -p $W
  mtype -i $V ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon > $W/addon.bin; mtype -i $V ::/EFI/UniXNU/Payloads/kernel.macho.trustcache > $W/trust.bin
  ls -l $W/addon.bin $W/trust.bin; sha256sum $W/addon.bin $W/trust.bin | cut -c1-16
  python3 $E/fit-addon.py $W/addon.bin $W/addon.bin $W/fit.bin; cmp $W/addon.bin $W/fit.bin && echo "fit identical"
  python3 - $W/trust.bin > $W/hashes.txt <<'EOF'
import struct,sys
d=open(sys.argv[1],'rb').read()
n=struct.unpack_from('<I',d)[0]; s=struct.unpack_from('<I',d,4)[0]
c=struct.unpack_from('<I',d,s+20)[0]
for i in range(c):
    print(d[s+24+i*24:s+44+i*24].hex(), 'entry', d[s+44+i*24:s+48+i*24].hex())
EOF
  cat $W/hashes.txt
  python3 $E/patch-trustcache.py $W/trust.bin $W/hashes.txt $W/trust2.bin | tail -2; cmp $W/trust.bin $W/trust2.bin && echo "trust identical"
done
echo "== fat-inplace usage"
sed -n 1,15p $E/fat-inplace.py
echo "== COM3 helpers"
ls $E | grep -i -E 'com3|serial' || echo none
