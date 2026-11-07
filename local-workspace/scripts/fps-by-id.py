#!/usr/bin/env python3
"""True frame rate from swap ids (the W ring drops rows, so counting rows undercounts), next to the scanout wait counters.

Usage: fps-by-id.py <decoded log dir> [window seconds]
"""
import re
import sys
from pathlib import Path
from statistics import median

ROW = re.compile(r'(?m)^W(\d+) t=([\d.]+)s \+(-?\d+)ms offer=(-?\d+)ms done=(-?\d+)ms')
d = Path(sys.argv[1])
win = float(sys.argv[2]) if len(sys.argv) > 2 else 30.0
text = (d / 'slots.txt').read_text(errors='replace')

rows = {}
for m in ROW.finditer(text):
    rows[int(m[1])] = (float(m[2]), int(m[3]), int(m[4]), int(m[5]))
ids = sorted(rows)
print('rows %d, ids %d-%d (%d frames), recorded %.0f%%' % (len(ids), ids[0], ids[-1], ids[-1] - ids[0] + 1,
                                                           100 * len(ids) / (ids[-1] - ids[0] + 1)))
t0, t1 = rows[ids[0]][0], rows[ids[-1]][0]
print('%8s %6s %6s %8s %8s %8s %8s %8s' % ('window', 'rows', 'frames', 'rows/s', 'fps(id)', 'gap med', 'done med', 'gap max'))
s = t0
while s < t1:
    e = s + win
    inside = [i for i in ids if s <= rows[i][0] < e]
    if len(inside) >= 2:
        span = rows[inside[-1]][0] - rows[inside[0]][0]
        frames = inside[-1] - inside[0]
        gaps = [rows[b][0] - rows[a][0] for a, b in zip(inside, inside[1:]) if b == a + 1]
        dones = [rows[i][3] for i in inside]
        print('%8.0f %6d %6d %8.1f %8.1f %8.1f %8.1f %8.1f' % (
            s, len(inside), frames, (len(inside) - 1) / span if span else 0, frames / span if span else 0,
            1000 * median(gaps) if gaps else -1, median(dones), 1000 * max(gaps) if gaps else -1))
    else:
        print('%8.0f %6d   no frames' % (s, len(inside)))
    s = e

print('\nslot timeline: t, scanout wait calls/timeouts, delta per slot')
pc = pt = 0
n = 0
for block in re.split(r'(?m)^(?=#slot )', text):
    h = re.match(r'#slot (\d+) t=(\d+)s', block)
    w = re.search(r'\[scanout wait\] calls=(\d+) timeouts=(\d+)', block)
    if not h or not w:
        continue
    c, to = int(w[1]), int(w[2])
    n += 1
    if n % 8 == 1:
        off = re.search(r'gpu_offers=(\d+)|offers=(\d+)', block)
        print('  t=%4ss calls=%5d timeouts=%4d  +calls=%4d +timeouts=%3d %s' % (h[2], c, to, c - pc, to - pt, off[0] if off else ''))
        pc, pt = c, to
