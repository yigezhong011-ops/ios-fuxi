#!/usr/bin/env python3
# Read only: what the COM3 log of a run says around the last FUXI120S rows, GPU and panic words first. Usage: <log>
import re, sys
b = open(sys.argv[1], 'rb').read().decode('utf-8', 'replace')
L = b.splitlines()
print('lines', len(L), 'bytes', len(b))
rows = [i for i, x in enumerate(L) if 'FUXI120S' in x]
start = rows[-6] if len(rows) > 6 else 0
pat = re.compile(r'panic|fault|hang|timeout|timed out|recover|reset|stall|GMU|gmu|SMMU|smmu|watchdog|kgsl|ring|hard|Adreno|adreno|gpu|GPU|jetsam|OOM|exception', re.I)
hits = [x for x in L[start:] if pat.search(x) and 'FUXI120S' not in x]
print('rows from', start, 'hits after it', len(hits))
seen = {}
for x in hits:
    k = re.sub(r'[0-9a-fx]{3,}', '#', x)[:80]
    seen[k] = seen.get(k, 0) + 1
    if seen[k] <= 2:
        print(x[:190])
print('--- kinds')
for k, n in sorted(seen.items(), key=lambda kv: -kv[1])[:20]:
    print(n, k)
print('--- last 25 lines'); print('\n'.join(x[:170] for x in L[-25:]))
