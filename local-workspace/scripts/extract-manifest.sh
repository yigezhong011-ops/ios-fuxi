#!/bin/bash
set -euo pipefail
I=/mnt/e/DSH-Fuxi/dump/iphonex-16.7.11.ipsw
W=/root/fuxi/build-x
mkdir -p "$W"
cd "$W"
echo "=== 提取 BuildManifest + 设备树 ==="
unzip -o -j "$I" BuildManifest.plist -d "$W" >/dev/null
unzip -o -j "$I" 'Firmware/all_flash/DeviceTree.d22ap.im4p' -d "$W" >/dev/null
ls -l "$W"/BuildManifest.plist "$W"/DeviceTree.d22ap.im4p
echo
echo "=== BuildManifest 里的镜像角色 ==="
python3 - "$W/BuildManifest.plist" <<'PY'
import plistlib, sys
m = plistlib.load(open(sys.argv[1], 'rb'))
ident = m.get('ProductBuildVersion'), m.get('ProductVersion')
print('build/version:', ident)
for dev, info in m.get('BuildIdentities', {}).items():
    seen = set()
    for name, ent in info.get('Manifest', {}).items():
        di = ent.get('Info', {})
        path = di.get('Path')
        if path and path.endswith('.dmg') and path not in seen:
            seen.add(path)
            print(f'{name:22} {path:24} {di.get("IsFTAB", False)}')
PY
