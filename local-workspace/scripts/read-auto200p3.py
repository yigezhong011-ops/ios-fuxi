#!/usr/bin/env python3
"""Compare the boot before with the auto200p boot, split at the boot-args block. Read-only. Usage: read-auto200p3.py <old lscan> <new lscan> <log dir>"""
import hashlib
import re
import sys
from collections import Counter
from pathlib import Path

old, new, logdir = sys.argv[1:4]
A0, SPLIT = 224118197576, 225558362720
WIDGET = re.compile(r'(?i)chrono|widget|WGWidget|timeline|snapshot|archive|placeholder')
NOISE = re.compile(r'RBS|RBAssertion|osservice<|caching container|xpcservice<|\[app<|Couldn|LaunchServices')


def blocks(path):
    b = open(path, 'rb').read()
    marks = list(re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b))
    for i, m in enumerate(marks):
        end = marks[i + 1].start() if i + 1 < len(marks) else len(b)
        yield int(m.group(1)), b[m.end():end]


seen = {hashlib.sha1(c).digest() for _, c in blocks(old)}
fresh = sorted((o, c) for o, c in blocks(new) if hashlib.sha1(c).digest() not in seen)
b1 = b''.join(c for o, c in fresh if A0 <= o < SPLIT).decode('latin1')
b2 = b''.join(c for o, c in fresh if o >= SPLIT and o < 230 * 10**9).decode('latin1')
print('boot before bytes', len(b1), ' auto200p bytes', len(b2))


def norm(l):
    return re.sub(r'0x[0-9a-f]+|[0-9A-Fa-f]{8}-[0-9A-Fa-f-]{27}|\d+', '#', l)[:140]


def bag(t):
    return Counter(norm(l) for l in t.split('\n') if WIDGET.search(l) and not NOISE.search(l) and len(l) > 25)


c1, c2 = bag(b1), bag(b2)
print('widget lines', sum(c1.values()), sum(c2.values()), ' private in widget lines', sum(v for k, v in c1.items() if '<private>' in k), sum(v for k, v in c2.items() if '<private>' in k))
print('== widget messages only in auto200p (top 45)')
for k, v in Counter({k: v for k, v in c2.items() if k not in c1}).most_common(45):
    print(f'{v:5d} {k}')
print('== widget messages only in the boot before (top 45)')
for k, v in Counter({k: v for k, v in c1.items() if k not in c2}).most_common(45):
    print(f'{v:5d} {k}')
print('== both, biggest count change (top 20)')
for k in sorted(set(c1) & set(c2), key=lambda k: -abs(c1[k] - c2[k]))[:20]:
    print(f'{c1[k]:5d} {c2[k]:5d} {k}')
lines = b2.split('\n')
print('== store error context, auto200p')
for i, l in enumerate(lines):
    if 'generalErrorDomain' in l:
        for x in lines[max(0, i - 14):i + 6]:
            print('   ', x[:190])
print('== private or poster subsystem traces, each boot')
for pat in ('com.apple.PosterBoard', 'com.apple.posterkit.provider', 'com.apple.PosterKit', 'com.apple.posterboardservices', 'Default-Privacy-Setting', 'Logging/Subsystems'):
    print(f'{b1.count(pat):7d} {b2.count(pat):7d} {pat}')
d = Path(logdir)
s = (d / 'slots.txt').read_text(errors='replace')
print('== mount rows', Counter(re.sub(r'\d+\.\d+', '#', x)[:170] for x in re.findall(r'(?m)^.*(?:mount=|mount2=|mount3=|ngpu).*$', s)).most_common(5))
