#!/usr/bin/env python3
"""Does the ZAP the user supplied match the pin the build embeds?"""
import hashlib
import json
from pathlib import Path

pins_path = Path('/mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/data/fuxi-adreno-inputs.json')
d = json.loads(pins_path.read_text())
files = d['firmware']['files']

print('=== 仓库 pin 的 fuxi 固件 ===')
for k, v in files.items():
    print('  %-42s %8s bytes  %s' % (k, v.get('bytes'), v.get('sha256')))

print()
zap = pins_path.parent.parent.parent / 'placeholder'
user = Path('/mnt/c/Users/USER/Downloads/a740_zap-odm.mbn').read_bytes()
h = hashlib.sha256(user).hexdigest()
print('=== 你给的 ZAP ===')
print('  bytes %d  sha256 %s' % (len(user), h))

pin = files.get('qcom/sm8550/fuxi/a740_zap.mbn') or files.get('qcom/sm8550/sheng/a740_zap.mbn')
if pin:
    match = (pin.get('sha256') == h)
    print()
    print('  与 pin 一致:', match)
    if not match:
        print('  pin 期望:', pin.get('sha256'))
