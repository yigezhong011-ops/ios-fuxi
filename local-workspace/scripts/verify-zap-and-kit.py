#!/usr/bin/env python3
"""Confirm the two ODM ZAP files are the ones the fork pins, and check whether
the tree assembly copies the device package into kits/<kit>."""
import hashlib
import json
import subprocess
from pathlib import Path

for name in ('a740_zap-odm-fd107982.mbn', 'a740_zap-odm.mbn'):
    p = Path('/mnt/c/Users/USER/Downloads') / name
    b = p.read_bytes()
    print('%-30s %6d B  sha256 %s' % (name, len(b), hashlib.sha256(b).hexdigest()[:32]))

repo = Path('/root/fuxi/fork-device/blobs/a740_zap.mbn')
if repo.is_file():
    b = repo.read_bytes()
    print('%-30s %6d B  sha256 %s' % ('blobs/a740_zap.mbn', len(b), hashlib.sha256(b).hexdigest()[:32]))

pins = json.loads((Path('/root/fuxi/fork-device/scripts/data/fuxi-adreno-inputs.json')).read_text())
print('pin:', json.dumps(pins['firmware']['files']['qcom/sm8550/fuxi/a740_zap.mbn'], indent=1))

kit = Path('/root/ux2/fuxi/tree/kits/sheng/libFuxiLinkStubs.a')
print('树里的 stub:', kit.exists(), kit)
kitdir = Path('/root/ux2/fuxi/tree/kits/sheng')
if kitdir.is_dir():
    names = sorted(p.name for p in kitdir.iterdir())[:12]
    print('kits/sheng 内容:', names)
