#!/usr/bin/env python3
"""Inspect the firmware pin entry: what fields point at the ZAP blob, so the
board's own signed a740_zap.mbn can replace it."""
import hashlib
import json
import pathlib
import subprocess

pins = Path('/root/fuxi/fork-device/scripts/data/fuxi-adreno-inputs.json')
d = json.loads(pins.read_text())
zap = d['firmware']['files']['qcom/sm8550/fuxi/a740_zap.mbn']
print('=== 当前 zap pin ===')
for k, v in zap.items():
    print('  %-18s %s' % (k, v))

# 我们手上 fuxi ODM 的 ZAP
local = Path('/mnt/c/Users/USER/Downloads/a740_zap-odm.mbn')
b = local.read_bytes()
print()
print('=== 本地 ODM ZAP ===')
print('  bytes  %d' % len(b))
print('  sha256 %s' % hashlib.sha256(b).hexdigest())
blob_sha = hashlib.sha1(b'blob %d\0' % len(b) + b).hexdigest()
print('  git blob sha1 %s' % blob_sha)
