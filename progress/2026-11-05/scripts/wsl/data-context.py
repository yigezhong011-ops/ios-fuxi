#!/usr/bin/env python3
"""Print printable context around chosen offsets of the Data image.

Usage: data-context.py <offset> [<offset> ...]   (decimal or 0x...)
"""
import re
import sys
from pathlib import Path

IMG = Path('/mnt/e/DSH-Fuxi/logs/data-raw.img')
SPAN = 320


def printable(blob):
    out = []
    run = bytearray()
    for b in blob:
        if 32 <= b < 127:
            run.append(b)
        else:
            if len(run) >= 4:
                out.append(run.decode('ascii'))
            run = bytearray()
    if len(run) >= 4:
        out.append(run.decode('ascii'))
    return out


with IMG.open('rb') as fh:
    size = IMG.stat().st_size
    for arg in sys.argv[1:]:
        off = int(arg, 0)
        lo = max(0, off - SPAN)
        fh.seek(lo)
        blob = fh.read(SPAN * 2)
        print('=' * 70)
        print('offset 0x%x (±%d)' % (off, SPAN))
        for s in printable(blob):
            print('   %s' % s[:300])
