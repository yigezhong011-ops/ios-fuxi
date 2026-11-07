#!/usr/bin/env python3
"""Replace the hardcoded chip id in the build scripts with an environment variable, so
the progress sync can publish them."""
import re
from pathlib import Path

FILES = [
    '/mnt/e/DSH-Fuxi/dump/wsl/pack-addon.py',
    '/mnt/e/DSH-Fuxi/dump/wsl/rebuild-step2.sh',
    '/mnt/e/DSH-Fuxi/dump/wsl/rebuild-step3.sh',
    '/mnt/e/DSH-Fuxi/dump/wsl/rebuild-step4.sh',
    '/mnt/e/DSH-Fuxi/dump/wsl/build-wall-variant.sh',
    '/mnt/e/DSH-Fuxi/dump/wsl/build-wall3.sh',
    '/root/fuxi/ios-fuxi/progress/2026-11-03/scripts/wsl/build-wall-variant.sh',
    '/root/fuxi/ios-fuxi/progress/2026-11-03/scripts/wsl/rebuild-step2.sh',
    '/root/fuxi/ios-fuxi/progress/2026-11-03/scripts/wsl/rebuild-step3.sh',
    '/root/fuxi/ios-fuxi/progress/2026-11-03/scripts/wsl/rebuild-step4.sh',
]

PATTERN = re.compile(r'--unique-chip-id\s+0x[0-9a-fA-F]+')

for name in FILES:
    p = Path(name)
    if not p.exists():
        continue
    text = p.read_text(errors='replace')
    if not PATTERN.search(text):
        continue
    new = PATTERN.sub('--unique-chip-id "${UNIXNU_UNIQUE_CHIP_ID:?set the device platform seed}"', text)
    p.write_text(new)
    print('已替换', name)
