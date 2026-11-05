#!/usr/bin/env python3
"""Frame rate per time window, so idle and swiping phases can be compared in one boot.

Usage: fps-phases.py <decoded log dir> [window seconds]
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
    rows[int(m[1])] = float(m[2])
ids = sorted(rows)
if len(ids) < 5:
    sys.exit('swap 太少: %d' % len(ids))

t0, t1 = rows[ids[0]], rows[ids[-1]]
print('swap %d 个，跨度 %.1f s（%.1f → %.1f）' % (len(ids), t1 - t0, t0, t1))

# 每个时间窗的帧数与中位间隔
start = t0
while start < t1:
    end = start + win
    inside = [i for i in ids if start <= rows[i] < end]
    if len(inside) >= 3:
        span = rows[inside[-1]] - rows[inside[0]]
        fps = (len(inside) - 1) / span if span > 0 else 0
        gaps = [rows[b] - rows[a] for a, b in zip(inside, inside[1:])]
        print('  %6.1f–%6.1f s  %4d 帧  %6.1f fps  中位间隔 %5.1f ms  最大间隔 %6.1f ms'
              % (start - t0, end - t0, len(inside), fps, median(gaps) * 1000, max(gaps) * 1000))
    else:
        print('  %6.1f–%6.1f s  帧太少（%d）' % (start - t0, end - t0, len(inside)))
    start = end
