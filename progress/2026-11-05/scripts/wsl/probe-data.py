#!/usr/bin/env python3
"""Answer the three questions the handoff asks about the Data copy.

The image is a 16 GiB slice of Data that does not start at the APFS container header, so it
cannot be mounted; the analysis is a byte search for the paths plus whatever sits next to
them. Read-only: the image is opened 'rb' and never written.

Usage: probe-data.py [image]
"""
import re
import sys
from pathlib import Path

IMG = Path(sys.argv[1] if len(sys.argv) > 1 else '/mnt/e/DSH-Fuxi/logs/data-raw.img')
NEEDLES = {
    'poster_store_path': b'PRBPosterExtensionDataStore',
    'container_uuid': b'353FB615-9AD2-407D-B79C-EFF255D5432B',
    'ngpu_wallpaper': b'/private/var/ngpu/wallpaper',
    'wallpaper_word': b'ngpu/wallpaper',
    'migration_plist': b'com.apple.migration.plist',
    'sqlite_header': b'SQLite format 3\x00',
    'bokeh_5010': b'5010.iPadOS',
    'default_plists': b'DefaultWallpapers~',
}
CHUNK = 64 << 20
# how many hits to keep per needle (offsets only, the image is 16 GiB)
LIMIT = 40

hits = {k: [] for k in NEEDLES}
carry = b''
base = 0
size = IMG.stat().st_size
print('image %s  %.2f GiB' % (IMG, size / 2**30))

with IMG.open('rb') as fh:
    while True:
        block = fh.read(CHUNK)
        if not block:
            break
        buf = carry + block
        for key, needle in NEEDLES.items():
            if len(hits[key]) >= LIMIT:
                continue
            start = 0
            while True:
                at = buf.find(needle, start)
                if at < 0:
                    break
                off = base - len(carry) + at
                if off >= 0:
                    hits[key].append(off)
                start = at + 1
                if len(hits[key]) >= LIMIT:
                    break
        carry = buf[-4096:]
        base += len(block)

for key in NEEDLES:
    offs = hits[key]
    print('\n%-18s 命中 %d 处%s' % (key, len(offs), '（已截断）' if len(offs) >= LIMIT else ''))
    for off in offs[:12]:
        print('   0x%x' % off)
