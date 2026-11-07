#!/usr/bin/env python3
"""Lag and widgets from a pulled log: progress over time of frames, priming and clocks. Read-only.
Usage: decode-gpu2-log.py <log dir>"""
import re
import sys
from pathlib import Path

d = next(Path(sys.argv[1]).glob('*/'))
text = (d / 'slots.txt').read_text(errors='replace')
slots = re.split(r'(?m)^(?=#slot )', text)
slots = [s for s in slots if s.startswith('#slot')]
print('slots', len(slots), (d / 'header.txt').read_text().split('uptime_s=')[1].split()[0], 's')


def get(s, pat, default=''):
    m = re.search(pat, s, re.M)
    return m.group(1) if m else default


print('t | commits pipelines | gpu ctc mean | V hit/miss | PR | fence-timeouts | scanout-timeouts | gpu perf | cpu | swap gaps ms mean/max')
step = max(1, len(slots) // 26)
for s in slots[::step] + slots[-1:]:
    t = get(s, r'^#slot \d+ t=(\d+)s')
    c = get(s, r'^S c(\d+)')
    p = get(s, r'^S c\d+/\d+ d\d+ p(\d+)')
    g = get(s, r'^G commit-to-complete .*mean=(\d+)us')
    v = get(s, r'^V cache (hit\d+ miss\d+ wr\d+)')
    pr = get(s, r'^PR (.*)$')[:60]
    fw = get(s, r'^\[fence wait\] calls=\d+ timeouts=(\d+)')
    sw = get(s, r'^\[scanout wait\] calls=\d+ timeouts=(\d+)')
    gp = get(s, r'gpu perf (\d+ bw \d+)')
    cl = get(s, r'^\[clocks\] CPUFREQ (d0:\S+ c\d+)')
    gaps = [int(x) for x in re.findall(r'^W\d+ t=[\d.]+s \+(\d+)ms', s, re.M)]
    gm = '%d/%d' % (sum(gaps) / len(gaps), max(gaps)) if gaps else '-'
    print(t, c, p, g, v, '|', pr, '|', fw, sw, gp, cl, gm)

last = slots[-1]
print('== latest rows')
for line in last.splitlines():
    if re.match(r'(X[0-9] |W[01] |S c|T |G |J |N |V |L |W |Wb|F |PR|P\d|FA\d|\[gpu|\[metal askers|\[fence wait|\[scanout wait|\[stall\] fence|\[bo pool|\[clocks|\[vm map|\[vm unmap|\[coherence|\[touch\])', line):
        print(line[:230])
print('== distinct warnings')
from collections import Counter
c = Counter()
for s in slots:
    lines = s.splitlines()
    for i, line in enumerate(lines):
        if re.match(r'(W|P\d) ', line):
            nxt = lines[i + 1] if i + 1 < len(lines) and re.match(r'(Wb|P\db) ', lines[i + 1]) else ''
            c[(line + ' ' + nxt)[:200]] += 1
for k, v in c.most_common(30):
    print(v, k)
msg = (d / 'msgbuf.txt').read_text(errors='replace').replace('\0', '')
print('== msgbuf: widget/poster/jetsam/exits')
for pat in (r'WidgetRenderer', r'PosterBoard', r'CollectionsPoster', r'chronod', r'jetsam|Jetsam', r'memorystatus', r'exited|crash|EXC_', r'prime'):
    hits = re.findall(r'.{0,60}(?:%s).{0,110}' % pat, msg)
    print('--', pat, len(hits))
    for h in Counter(re.sub(r'\[ *[\d.]+\]:', '', x)[:170] for x in hits).most_common(6):
        print('  ', h[1], h[0])
