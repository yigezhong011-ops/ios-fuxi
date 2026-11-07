#!/usr/bin/env python3
"""Why is it slow: compare the two new-plugin logs, and look at CPU topology. Read-only."""
import re
from pathlib import Path


def load(name):
    d = next(Path('/root/fuxi', name).glob('*/'))
    t = (d / 'slots.txt').read_text(errors='replace')
    s = [x for x in re.split(r'(?m)^(?=#slot )', t) if x.startswith('#slot')]
    return d, s


pat = r'(S c|G commit|J (scheduled|completed)|\[fence wait\] (calls|outer)|\[scanout wait|\[clocks|\[gpu clients|\[stall\] fence|\[coherence|PR |X3 |X4 |X5 |\[gpu methods)'
for name in ('log-gpufix', 'log-gpu2'):
    d, s = load(name)
    print('=====', name, 'slots', len(s), 'files', sorted(p.name for p in d.iterdir()))
    for line in s[-1].splitlines():
        if re.match(pat, line):
            print(line[:210])
    # GPU commit-to-complete per interval
    prev = None
    rows = []
    for x in s:
        t = re.search(r'^#slot \d+ t=(\d+)s', x, re.M)
        m = re.search(r'^G commit-to-complete n=(\d+) total=(\d+)ms', x, re.M)
        if t and m:
            n, tot = int(m[1]), int(m[2])
            if prev and n > prev[0]:
                rows.append('%ss n+%d %dms/frame' % (t[1], n - prev[0], (tot - prev[1]) / (n - prev[0])))
            prev = (n, tot)
    print('per-interval ctc:', rows[:40])
    msg = (d / 'msgbuf.txt').read_text(errors='replace').replace('\0', '')
    print('-- msgbuf cpu lines')
    seen = set()
    for m in re.finditer(r'[^\n]{0,70}(cpu_count|ncpu|logical_cpu|cluster_type|cluster \d|CPUFREQ|cpufreq|cores? online|cpu\d+ (start|online)|Started cpu|processor_start|sheng-[a-z-]*(cpu|freq|core)[a-z-]*)[^\n]{0,90}', msg, re.I):
        k = re.sub(r'\d+', 'N', m[0])[:90]
        if k not in seen:
            seen.add(k)
            print('  ', m[0][:170])
        if len(seen) > 25:
            break
    bootargs = re.search(r'[^\n]{0,20}sheng-vsync[^\n]{0,900}', msg)
    if bootargs:
        print('-- args:', bootargs[0][:1000])

d, s = load('log-gpu2')
print('===== unfiltered last slot, non-repeating categories')
keep = []
for line in s[-1].splitlines():
    if not re.match(r'(W |Wb|P\d|FA|K\d|H\d)', line):
        keep.append(line[:170])
print('\n'.join(keep[:90]))
