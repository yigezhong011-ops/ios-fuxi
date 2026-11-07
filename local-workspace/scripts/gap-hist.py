#!/usr/bin/env python3
"""Histogram of frame gaps from consecutive W rows, split into busy runs. Usage: gap-hist.py <decoded dir> <from t> [idle ms]"""
import re, sys
from pathlib import Path
from statistics import median
ROW = re.compile(r'(?m)^W(\d+) t=([\d.]+)s \+(-?\d+)ms offer=(-?\d+)ms done=(-?\d+)ms')
text = (Path(sys.argv[1]) / 'slots.txt').read_text(errors='replace')
start = float(sys.argv[2]); idle = float(sys.argv[3]) if len(sys.argv) > 3 else 100
rows = {int(m[1]): (float(m[2]), int(m[3]), int(m[4]), int(m[5])) for m in ROW.finditer(text)}
ids = sorted(i for i in rows if rows[i][0] >= start)
gaps = [(rows[b][0] - rows[a][0]) * 1000 for a, b in zip(ids, ids[1:]) if b == a + 1]
plus = [rows[b][1] for a, b in zip(ids, ids[1:]) if b == a + 1]
print('consecutive pairs', len(gaps), 'of', len(ids))
edges = [0, 5, 7, 10, 13, 15, 18, 22, 30, 40, 60, 100, 1e9]
for lo, hi in zip(edges, edges[1:]):
    n = sum(lo <= g < hi for g in gaps)
    print(f'{lo:>4.0f}-{hi if hi < 1e8 else 9999:>5.0f} ms {n:>5} {100 * n / len(gaps):5.1f}% ' + '#' * int(60 * n / len(gaps)))
busy = [g for g in gaps if g < idle]
print('below idle: median %.1f ms = %.0f fps; mean %.1f ms = %.0f fps' % (median(busy), 1000 / median(busy), sum(busy) / len(busy), 1000 * len(busy) / sum(busy)))
print('gaps >= idle:', len(gaps) - len(busy))
for name, k in (('offer', 2), ('done', 3)):
    v = sorted(rows[i][k] for i in ids)
    print(name, 'p50', v[len(v) // 2], 'p90', v[len(v) * 9 // 10], 'p99', v[len(v) * 99 // 100], 'max', v[-1])
print('sample:'); [print(' ', re.search(rf'(?m)^W{i} .*$', text)[0][:130]) for i in ids[200:206]]
