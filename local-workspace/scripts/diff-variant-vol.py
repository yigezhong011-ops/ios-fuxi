#!/usr/bin/env python3
"""Where an edited payload volume differs from its source: changed byte ranges merged per 64 KiB, with the file each falls in
(by mtools cluster map) or 'FREE' (the packed Data seed lives in free clusters). Usage: diff-variant-vol.py <src.img> <edited.img>"""
import subprocess
import sys

a, b = open(sys.argv[1], 'rb').read(), open(sys.argv[2], 'rb').read()
step = 1 << 16
runs = []
for off in range(0, min(len(a), len(b)), step):
    if a[off:off + step] != b[off:off + step]:
        if runs and runs[-1][1] == off:
            runs[-1][1] = off + step
        else:
            runs.append([off, off + step])
print(f'{len(runs)} changed ranges')
for s, e in runs:
    print(f'  {s:#010x}..{e:#010x} ({(e - s) >> 10} KiB)')
