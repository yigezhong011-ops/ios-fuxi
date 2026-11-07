#!/usr/bin/env python3
"""When did the Data area grow in the apps boot, compared with a normal boot? Read-only."""
import re
from pathlib import Path

for name in ('daily1', 'apps2'):
    d = next(Path(f'/root/fuxi/log-cmp-{name}').glob('*/'))
    text = (d / 'slots.txt').read_text(errors='replace')
    rows = []
    for s in re.split(r'(?m)^(?=#slot )', text):
        t = re.match(r'#slot \d+ t=(\d+)s', s)
        m = re.search(r'^D st=\d+ .*?pres=(\d+) ld=(\d+) wr=(\d+) cm=(\d+)', s, re.M)
        if t and m:
            rows.append((int(t[1]), *map(int, m.groups())))
    rows.sort()
    print('==', name, 'rows', len(rows), '(t pres +pres wr +wr cm)')
    prev = None
    for r in rows:
        if prev is None or r[0] // 15 != prev[0] // 15 or r[1] - prev[1] > 3000:
            print(f'  t={r[0]:4d} pres={r[1]} +{r[1] - prev[1] if prev else 0:6d} wr={r[3]} +{r[3] - prev[3] if prev else 0:6d} cm={r[4]}')
            prev = r
    msg = (d / 'msgbuf.txt').read_text(errors='replace').replace('\0', '')
    st = re.findall(r'\[ *([\d.]+)\]', msg)
    print('  msgbuf span', st[:1], st[-1:], 'chars', len(msg))
