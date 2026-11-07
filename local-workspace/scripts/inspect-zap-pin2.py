#!/usr/bin/env python3
"""Inspect the firmware pin entry and compute the local ZAP's identifiers."""
import hashlib
import json
from pathlib import Path

pins = Path('/root/fuxi/fork-device/scripts/data/fuxi-adreno-inputs.json')
d = json.loads(pins.read_text())
zap = d['firmware']['files']['qcom/sm8550/fuxi/a740_zap.mbn']
print('=== 当前 zap pin ===')
for k, v in zap.items():
    print('  %-18s %s' % (k, v))

local = Path('/mnt/c/Users/USER/Downloads/a740_zap-odm.mbn')
b = local.read_bytes()
print()
print('=== 本地 ODM ZAP ===')
print('  bytes          %d' % len(b))
print('  sha256         %s' % hashlib.sha256(b).hexdigest())
print('  git blob sha1  %s' % hashlib.sha1(b'blob %d\0' % len(b) + b).hexdigest())

print()
print('=== 其它两个固件的 pin ===')
for k in ('qcom/gmu_gen70200.bin', 'qcom/sm8550/fuxi/a740_sqe.fw'):
    e = d['firmware']['files'].get(k, {})
    print('  %-34s %s bytes  %s' % (k, e.get('bytes'), str(e.get('sha256'))[:16]))
