#!/usr/bin/env python3
"""Compare every staged input against its pinned sha256."""
import hashlib
import json
from pathlib import Path

pins = json.loads(Path('/root/ux3/fuxi/tree/scripts/data/adreno-inputs.json').read_text())
staged = Path('/root/fuxi/fork-device/build/adreno-inputs')

bad = []
for section, info in pins.items():
    if not isinstance(info, dict):
        continue
    for name, entry in info.get('files', {}).items():
        p = staged / name
        if not p.is_file():
            bad.append((section, name, 'missing'))
            continue
        got = hashlib.sha256(p.read_bytes()).hexdigest()
        want = entry.get('sha256')
        if want and got != want:
            bad.append((section, name, '%s != %s' % (got[:12], want[:12])))

print('不一致:', len(bad))
for section, name, why in bad[:10]:
    print('  %-8s %-52s %s' % (section, name, why))
