#!/bin/bash
set -uo pipefail
W=/root/fuxi/build-x
python3 - "$W/BuildManifest.plist" <<'PY'
import plistlib, sys
m = plistlib.load(open(sys.argv[1], 'rb'))
print('build/version:', m.get('ProductBuildVersion'), m.get('ProductVersion'))
ident = m['BuildIdentities'][0]
print('identity:', ident.get('Info', {}).get('DeviceClass'), ident.get('Info', {}).get('ProductType'))
seen = set()
for name, ent in ident.get('Manifest', {}).items():
    di = ent.get('Info', {})
    path = di.get('Path')
    if path and path.endswith('.dmg') and path not in seen:
        seen.add(path)
        print(f'{name:22} {path:26} size={di.get("IsFTAB", False)}')
PY
echo
echo "=== im4p 结构 ==="
python3 - "$W/DeviceTree.d22ap.im4p" <<'PY'
import sys, struct
d = open(sys.argv[1], 'rb').read()
print('magic:', d[:4], 'len:', len(d))
# IM4P: magic(4) + 3 x u32 lengths (?) then type string, desc
print(d[:64])
PY
