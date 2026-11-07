#!/usr/bin/env python3
"""Read-only: count identity and status bar strings in an lscan capture. Usage: read-ipx-log.py <lscan.txt>"""
import re
import sys

keys = [b'iPhone10,3', b'iPhone15,2', b'iPhone14,3', b'45025538', b'iPhone X', b'iPhone 14 Pro', b'2436', b'Fallback', b'_UIStatusBarVisualProvider',
        b'StatusBarVisualProvider', b'statusBarVisualProvider', b'Split58', b'DynamicSplit', b'MobileGestalt']
count = {k: 0 for k in keys}
samples = {k: [] for k in keys}
with open(sys.argv[1], 'rb') as f:
    for line in f:
        for k in keys:
            if k in line:
                count[k] += 1
                if len(samples[k]) < 4 and len(line) < 400:
                    samples[k].append(line.strip()[:200].decode('utf-8', 'replace'))
for k in keys:
    print(k.decode(), count[k])
    for s in samples[k]:
        print('    ', s)
