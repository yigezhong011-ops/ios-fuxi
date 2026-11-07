#!/bin/bash
set -uo pipefail
I=/mnt/e/DSH-Fuxi/dump/iphonex-16.7.16.ipsw
W=/root/fuxi/build-1616
mkdir -p "$W"
cd "$W"
echo "=== IPSW 校验 ==="
unzip -t "$I" 2>&1 | tail -2
echo
echo "=== 镜像角色 ==="
unzip -o -j "$I" BuildManifest.plist -d "$W" >/dev/null
python3 - "$W/BuildManifest.plist" <<'PY'
import plistlib, sys
m = plistlib.load(open(sys.argv[1], 'rb'))
print('version:', m.get('ProductVersion'), m.get('ProductBuildVersion'))
ident = m['BuildIdentities'][0]
seen = set()
for name, ent in ident.get('Manifest', {}).items():
    p = ent.get('Info', {}).get('Path')
    if p and p.endswith('.dmg') and p not in seen:
        seen.add(p)
        print(f'{name:22} {p}')
PY
