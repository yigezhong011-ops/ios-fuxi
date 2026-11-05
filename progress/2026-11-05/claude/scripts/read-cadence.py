#!/usr/bin/env python3
"""Swap cadence from the boot log's slots. Read-only. Usage: read-cadence.py <decoded log dir> [more dirs]"""
import re
import sys
from collections import Counter
from pathlib import Path
from statistics import median

ROW = re.compile(r'(?m)^W(\d+) t=([\d.]+)s \+(-?\d+)ms offer=(-?\d+)ms done=(-?\d+)ms')

for d in sys.argv[1:]:
    s = (Path(d) / 'slots.txt').read_text(errors='replace')
    rows = {}
    for m in ROW.finditer(s):
        rows[int(m[1])] = (float(m[2]), int(m[3]), int(m[4]), int(m[5]))
    ids = sorted(rows)
    print(f'== {d}')
    print('swaps recorded', len(ids), 'of ids', ids[0], '-', ids[-1], ' time span %.1f s' % (rows[ids[-1]][0] - rows[ids[0]][0]))
    # Runs of consecutive ids give real gaps; only those are honest about rate.
    runs, cur = [], [ids[0]]
    for i in ids[1:]:
        if i == cur[-1] + 1:
            cur.append(i)
        else:
            runs.append(cur); cur = [i]
    runs.append(cur)
    gaps = [rows[i][1] for r in runs for i in r[1:]]
    done = [rows[i][3] for r in runs for i in r if rows[i][3] >= 0]
    offer = [rows[i][2] for r in runs for i in r if rows[i][2] >= 0]
    print('runs', len(runs), 'gaps', len(gaps), 'median gap', median(gaps), 'ms; done median', median(done), 'max', max(done), '; offer median', median(offer), 'max', max(offer))
    bins = [(0, 5), (5, 10), (10, 13), (13, 20), (20, 30), (30, 40), (40, 60), (60, 120), (120, 10**9)]
    c = Counter()
    for g in gaps:
        for lo, hi in bins:
            if lo <= g < hi:
                c[(lo, hi)] += 1
    for b in bins:
        print(f'   {b[0]:>4}-{b[1] if b[1] < 10**8 else "up":<4} ms {c[b]:6d}  {100*c[b]/len(gaps):5.1f}%')
    # Busy stretches: within a run, frames per second over a sliding second, keeping gaps under 100 ms as continuous motion.
    best = []
    for r in runs:
        if len(r) < 8:
            continue
        span = rows[r[-1]][0] - rows[r[0]][0]
        if span > 0:
            best.append((round((len(r) - 1) / span, 1), len(r), round(rows[r[0]][0], 1), median(rows[i][3] for i in r)))
    print('run rate: fps, frames, start s, done median; lowest 8 and highest 8')
    best.sort()
    print('   low ', best[:8])
    print('   high', best[-8:])
    print('   median run fps', median(b[0] for b in best) if best else None)
    # Swap total against uptime: the honest overall average.
    slots = re.findall(r'(?m)^#slot (\d+) t=(\d+)s', s)
    pre = re.findall(r'prepare calls=(\d+)', s)
    print('prepare calls over time (every 10th slot):', [(slots[i][1] + 's', pre[i]) for i in range(0, min(len(slots), len(pre)), 10)])
    if len(pre) > 1:
        print('calls per 2 s slot, median over the last 60 slots', median(int(pre[i]) - int(pre[i - 1]) for i in range(max(1, len(pre) - 60), len(pre))))
    last = re.split(r'(?m)^#slot ', s)[-1]
    for row in re.findall(r'(?m)^X[3-6] .*$', last):
        print('  ', row[:120])
