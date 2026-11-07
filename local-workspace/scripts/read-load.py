#!/usr/bin/env python3
# Per-CPU busy share between successive "FUXI120 c<n> <busy> <idle>" samples, in the order the log has them. Ticks are cumulative.
import re, sys, pathlib
d = pathlib.Path(sys.argv[1])
msg = (d / 'msgbuf.txt').read_bytes().decode('latin1')
for p in sorted(d.iterdir()):
    pass
rows = re.findall(r'FUXI120 c([0-7]) ([0-9a-f]+) ([0-9a-f]+)', msg)
print('samples', len(rows), 'first offset', msg.find('FUXI120 c'), 'msgbuf bytes', len(msg))
sets = {}
for c, b, i in rows:
    sets.setdefault(int(c), []).append((int(b, 16), int(i, 16)))
n = min((len(v) for v in sets.values()), default=0)
print('rounds per cpu', {c: len(v) for c, v in sets.items()})
print('cumulative, last sample: busy idle busy%')
for c in sorted(sets):
    b, i = sets[c][-1]
    print(' c%d %8d %8d %5.1f%%' % (c, b, i, 100 * b / max(1, b + i)))
print('per interval busy% (cpu0..7), total ticks of cpu0 in the interval')
for k in range(1, n):
    out = []
    for c in sorted(sets):
        db = sets[c][k][0] - sets[c][k - 1][0]; di = sets[c][k][1] - sets[c][k - 1][1]
        out.append('%3d' % (100 * db / max(1, db + di)))
    db = sets[0][k][0] - sets[0][k - 1][0]; di = sets[0][k][1] - sets[0][k - 1][1]
    print(' %3d  %s   ticks %d' % (k, ' '.join(out), db + di))
for line in re.findall(r'FUXI120 (?!c[0-7] )[^\n]{0,60}', msg)[:12]:
    print(line)
