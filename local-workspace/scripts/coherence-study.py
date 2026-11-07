#!/usr/bin/env python3
"""Across every pulled log: does the coherence verdict go with the slow submits? Read-only."""
import re
import subprocess
from pathlib import Path

DEC = '/mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py'
for b in sorted(Path('/mnt/e/DSH-Fuxi/logs').glob('*.bin')):
    if b.stat().st_size < 1000000:
        continue
    o = Path('/root/fuxi/log-all') / b.stem
    if not o.exists():
        subprocess.run(['python3', '-I', DEC, '--decode', str(b), '--out', str(o)], capture_output=True)
    for d in o.glob('*/'):
        f = d / 'slots.txt'
        if not f.exists():
            continue
        s = [x for x in re.split(r'(?m)^(?=#slot )', f.read_text(errors='replace')) if x.startswith('#slot')]
        if not s:
            continue
        last = s[-1]
        coh = re.search(r'^\[coherence\] (.*)$', last, re.M)
        m5 = re.search(r' 5:(\d+)/\d+/(\d+)', last)
        g = re.search(r'^G commit-to-complete n=(\d+) .*mean=(\d+)us', last, re.M)
        cl = re.search(r'^\[gpu clients\] (.*)$', last, re.M)
        n = len(re.findall(r'\bs\d ', cl[1])) if cl else 0
        sub = '%dus' % (int(m5[2]) / max(1, int(m5[1]))) if m5 else '-'
        print(b.stem, d.name[:18], 'slots', len(s), '| ctc', g[2] if g else '-', 'n', g[1] if g else '-', '| submit', sub, '| clients', n)
        print('    ', coh[1][:150] if coh else 'no coherence row')
        # when did the verdict appear and did it change
        seen = []
        for x in s:
            c = re.search(r'^\[coherence\] H (d\d+/\d+ a\d+).*-> (\w+)', x, re.M)
            t = re.search(r't=(\d+)s', x)
            if c and (not seen or seen[-1][1:] != (c[1], c[2])):
                seen.append((t[1], c[1], c[2]))
        print('    ', seen[:10])
