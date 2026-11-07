#!/usr/bin/env python3
"""GPU submissions per swipe, grouped by core mask, from a COM3 log of ctl-run.
Each swipe is preceded by a probe (g=0), so the difference between the g=0 and g=2 lines covers that swipe only.
Usage: swipe-rate.py <com3 log> <mask per g=3 line, comma separated> [swipe ms]"""
import re
import statistics
import sys

text = open(sys.argv[1], 'rb').read().decode('utf-8', 'replace')
masks = sys.argv[2].split(',')
ms = int(sys.argv[3]) if len(sys.argv) > 3 else 1000
rows = [(int(g), int(i)) for g, i in re.findall(r'FUXI120S g=(\d+) .*? ibs=(\d+)', text)]
seg = -1; groups = []; prev = None
for g, ibs in rows:
    if g == 3:
        seg += 1; groups.append([]); prev = None
    elif g == 2 and prev is not None and seg >= 0:
        groups[seg].append(ibs - prev); prev = None
    elif g == 0:
        prev = ibs
    else:
        prev = None
for i, values in enumerate(groups):
    name = masks[i] if i < len(masks) else '?'
    if values:
        print('mask %-3s swipes %2d  per swipe %s  median %.0f  about %.0f per second' % (name, len(values), values, statistics.median(values), statistics.median(values) * 1000 / ms))
    else:
        print('mask', name, 'no swipes')
