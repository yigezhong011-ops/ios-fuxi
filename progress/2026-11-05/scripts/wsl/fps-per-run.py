#!/usr/bin/env python3
"""Real frame rate per contiguous swap run, not just the median gap.

Usage: fps-per-run.py <decoded log dir> [more dirs]
"""
import re
import sys
from pathlib import Path
from statistics import median

ROW = re.compile(r'(?m)^W(\d+) t=([\d.]+)s \+(-?\d+)ms offer=(-?\d+)ms done=(-?\d+)ms')

for d in sys.argv[1:]:
    text = (Path(d) / 'slots.txt').read_text(errors='replace')
    rows = {}
    for m in ROW.finditer(text):
        rows[int(m[1])] = float(m[2])
    ids = sorted(rows)
    if len(ids) < 2:
        print(d, 'swap 太少')
        continue
    runs, cur = [], [ids[0]]
    for i in ids[1:]:
        (cur.append(i) if i == cur[-1] + 1 else (runs.append(cur), cur := [i]))
    runs.append(cur)

    print('== %s' % d)
    print('  swap 总数 %d，连续区间 %d 个' % (len(ids), len(runs)))
    best = []
    for r in runs:
        if len(r) < 8:
            continue
        span = rows[r[-1]] - rows[r[0]]
        if span <= 0:
            continue
        fps = (len(r) - 1) / span
        gaps = [rows[b] - rows[a] * 1 for a, b in zip(r, r[1:])]
        best.append((fps, len(r), span, median(gaps) * 1000))
    best.sort(reverse=True)
    print('  帧率最高的 5 段（连续、>=8 帧）：')
    for fps, n, span, mg in best[:5]:
        print('    %6.1f fps  %3d 帧 / %5.1f s  中位间隔 %.1f ms' % (fps, n, span, mg))
    if best:
        print('  最佳 %.1f fps，中位 %.1f fps' % (best[0][0], median(b[0] for b in best)))
