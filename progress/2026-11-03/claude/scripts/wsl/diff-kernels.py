#!/usr/bin/env python3
"""Byte ranges where two kernel Mach-O files differ (merged when closer than 64 bytes). Usage: diff-kernels.py <a> <b>"""
import sys

a, b = open(sys.argv[1], 'rb').read(), open(sys.argv[2], 'rb').read()
print('sizes', len(a), len(b))
runs = []
for i in range(min(len(a), len(b))):
    if a[i] != b[i]:
        if runs and i - runs[-1][1] < 64:
            runs[-1][1] = i + 1
        else:
            runs.append([i, i + 1])
print(len(runs), 'ranges')
for s, e in runs[:20]:
    print(f'  file {s:#x}..{e:#x} ({e - s} bytes)')
