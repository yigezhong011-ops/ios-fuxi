#!/usr/bin/env python3
# Read only: compare a boot log of the branch plugin with a good boot. Message kinds that appear in only one, and the lines around the first rejected frame.
# Usage: read-m2v-boot.py <bad log> <good log>
import re, sys
def load(p): return open(p, 'rb').read().decode('utf-8', 'replace').splitlines()
def kind(x): return re.sub(r'0x[0-9a-fA-F]+|\b\d+\b', '#', re.sub(r'^\[?\s*[\d.]+\]?\s*', '', x))[:90]
bad, good = load(sys.argv[1]), load(sys.argv[2])
print('lines', len(bad), len(good))
for name, L in (('bad', bad), ('good', good)):
    print(name, 'verify_swap', sum('verify_swap' in x for x in L), 'FUXI120S', sum('FUXI120S' in x for x in L))
first = next((i for i, x in enumerate(bad) if 'verify_swap' in x), None)
print('first rejected line', first)
if first is not None:
    print('--- 50 lines before it')
    for x in bad[max(0, first - 50):first + 2]: print(x[:180])
gk, bk = {}, {}
for x in good: gk[kind(x)] = gk.get(kind(x), 0) + 1
for x in bad: bk[kind(x)] = bk.get(kind(x), 0) + 1
print('--- kinds only in bad');
for k, n in sorted(((k, n) for k, n in bk.items() if k not in gk), key=lambda a: -a[1])[:45]: print(n, k)
print('--- kinds only in good')
for k, n in sorted(((k, n) for k, n in gk.items() if k not in bk), key=lambda a: -a[1])[:25]: print(n, k)
pat = re.compile(r'adreno|turnip|vulkan|metal|mesa|gpu|tu_|freedreno|abi|version mismatch|IOSurface|backboard|WindowServer|QuartzCore|crash|exited|abort', re.I)
print('--- GPU words in bad, first of each kind')
seen = set()
for x in bad:
    if 'verify_swap' in x or 'FUXI120S' in x or not pat.search(x): continue
    k = kind(x)
    if k in seen: continue
    seen.add(k); print(x[:180])
    if len(seen) > 45: break
