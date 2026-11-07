#!/usr/bin/env python3
"""GPU submissions per swipe from a COM3 log, with no mask segments: each g=0 line followed by a g=2 line is one swipe."""
import re
import statistics
import sys

text = open(sys.argv[1], 'rb').read().decode('utf-8', 'replace')
rows = [(int(g), int(h), int(i)) for g, h, i in re.findall(r'FUXI120S g=(\d+) hid=(\d+) .*? ibs=(\d+)', text)]
values = []
for a, b in zip(rows, rows[1:]):
    if a[0] == 0 and b[0] == 2:
        values.append(b[2] - a[2])
print('swipes', len(values), values, 'median', statistics.median(values) if values else None)
print('panic lines', len(re.findall(r'panic\(|Debugger called', text)))
