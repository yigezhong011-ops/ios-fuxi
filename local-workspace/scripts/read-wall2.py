#!/usr/bin/env python3
"""Mount status, the store error's context in this boot and its count over all boots. Read-only. Usage: read-wall2.py <new.txt> <all lscan> <log dir>"""
import re
import sys
from collections import Counter
from pathlib import Path

new, allscan, logdir = sys.argv[1:4]
t = open(new, encoding='latin1').read()
lines = t.split('\n')
d = next(Path(logdir).glob('*/'))
s = (d / 'slots.txt').read_text(errors='replace')
print('== mount rows')
print(Counter(re.sub(r'\d+\.\d+', '#', x)[:200] for x in re.findall(r'(?m)^.*(?:mount=|mount2=|mount3=).*$', s)).most_common(4))
slots = [x for x in re.split(r'(?m)^(?=#slot )', s) if x.startswith('#slot')]
print('row kinds, last slot', Counter(l.split(' ')[0][:14] for l in slots[-1].splitlines()).most_common(40))
print((d / 'latest.txt').read_text(errors='replace')[:900])
print('== store error context this boot')
for i, l in enumerate(lines):
    if 'generalErrorDomain' in l:
        print(f'  -- line {i}')
        for x in lines[max(0, i - 45):i + 14]:
            print('    ', x[:210])
print('== poster messages in time order, this boot')
rx = re.compile(r'(?i)migrat|reap|data ?store|extension|descriptor|gallery|PRB|PBF|poster')
seen = Counter()
for l in lines:
    if rx.search(l) and not re.search(r'RBS|RBAssertion|osservice<|com\.apple\.\w+Poster|caching', l):
        key = re.sub(r'0x[0-9a-f]+|[0-9A-F]{8}-[0-9A-F-]{27}|\d+', '#', l)[:150]
        if seen[key] == 0:
            print('   ', l[:170])
        seen[key] += 1
        if len(seen) > 60:
            break
b = open(allscan, 'rb').read().decode('latin1')
print('== all boots')
print(Counter(re.findall(r'Error Domain=com\.apple\.PosterBoard\.generalErrorDomain Code=\d+ [^\n]{0,70}', b)).most_common(8))
print('migration finished', b.count('Data store migration finished'), 'initiated', b.count('Data store migration initiated'), 'not needed', b.count('Data store migration not needed'))
print('PosterBoard launches', len(set(re.findall(r'\[osservice<com\.apple\.PosterBoard>:(\d+)\]', b))))
