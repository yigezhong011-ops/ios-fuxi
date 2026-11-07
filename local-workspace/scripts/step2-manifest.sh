#!/bin/bash
set -euo pipefail
IPSW="/mnt/c/Users/USER/Desktop/小米13/dump/ipsw/iPhone10,3_16.7.16_20H392_Restore.ipsw"
mkdir -p /root/fuxi/ipsw
cd /root/fuxi
unzip -o -q "$IPSW" BuildManifest.plist -d ipsw
python3 - <<'PY'
import plistlib
d = plistlib.load(open('/root/fuxi/ipsw/BuildManifest.plist','rb'))
ident = d['BuildIdentities'][0]
print('ProductVersion:', d.get('ProductVersion'), 'Build:', d.get('BuildVersion'))
print('ProductType   :', d.get('ProductType'))
for k, v in ident['Manifest'].items():
    info = v.get('Info', {})
    path = info.get('Path')
    if path and path.endswith('.dmg'):
        print('%-28s %-18s %s' % (k, path, info.get('Size')))
PY
