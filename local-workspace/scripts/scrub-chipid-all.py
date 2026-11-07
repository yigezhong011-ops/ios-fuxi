#!/usr/bin/env python3
"""Scrub the device platform seed out of the build scripts staged for the progress repo."""
import re
from pathlib import Path

PATTERN = re.compile(r'--unique-chip-id\s+0x[0-9a-fA-F]+')
REPLACEMENT = '--unique-chip-id "${UNIXNU_UNIQUE_CHIP_ID:?set the device platform seed}"'

files = list(Path('/mnt/e/DSH-Fuxi/dump/wsl').glob('*.sh')) + \
        list(Path('/mnt/e/DSH-Fuxi/dump/wsl').glob('*.py')) + \
        list(Path('/root/fuxi/ios-fuxi/progress').rglob('*.sh')) + \
        list(Path('/root/fuxi/ios-fuxi/progress').rglob('*.py'))

for p in files:
    try:
        text = p.read_text(errors='replace')
    except Exception:
        continue
    if not PATTERN.search(text):
        continue
    p.write_text(PATTERN.sub(REPLACEMENT, text))
    print('已替换', p)
