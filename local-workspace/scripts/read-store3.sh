#!/bin/bash
# Read-only: what the store looks like now, and new poster messages compared with the previous capture.
A="python3 -I /mnt/e/DSH-Fuxi/dump/wsl/apfs-read.py /mnt/e/DSH-Fuxi/logs/data-raw.img"
B="mobile/Containers/Data/Application/353FB615-9AD2-407D-B79C-EFF255D5432B/Library/Application Support/PRBPosterExtensionDataStore"
$A ls 0 "$B" 2>&1 | cut -c1-110
for v in 59 60 61 62; do echo "== $v"; $A ls 0 "$B/$v" 2>&1 | tail -12 | cut -c1-110; done
python3 -I - <<'PY'
import hashlib, re
from collections import Counter
def blocks(p):
    b = open(p, 'rb').read()
    m = list(re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b))
    for i, x in enumerate(m):
        yield int(x.group(1)), b[x.end():m[i + 1].start() if i + 1 < len(m) else len(b)]
old = {hashlib.sha1(c).digest() for _, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-storefix/lscan.txt')}
new = [(o, c) for o, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-storefix2/lscan.txt') if hashlib.sha1(c).digest() not in old]
t = b'\n'.join(c for _, c in sorted(new)).decode('latin1')
print('fresh blocks', len(new), 'bytes', len(t))
for p in ('Data store could not be created', 'Data store migration', 'PRBPosterExtensionDataStore', 'failed to setup database', 'Reaping', 'generalErrorDomain', 'com.apple.PosterBoard', 'jetsam', 'ActiveHard', 'memorystatus', 'EXC_BREAKPOINT', 'dataStore'):
    print('%7d %s' % (t.count(p), p))
L = t.split('\n')
c = Counter()
for i, l in enumerate(L):
    if re.search(r'Data store|PosterExtensionDataStore|failed to setup|PRBPoster|PBF[A-Z]\w+.*(fail|error|could)', l):
        c[re.sub(r'0x[0-9a-f]+|[0-9A-F]{8}-[0-9A-F-]{27}|\d+', '#', l)[:170]] += 1
for k, v in c.most_common(25): print(v, k)
i = next((i for i, l in enumerate(L) if 'Data store could not be created' in l), None)
if i is not None:
    print('--- context of first store error')
    for x in L[max(0, i - 25):i + 6]: print('  ', ''.join(ch if 32 <= ord(ch) < 127 else '.' for ch in x)[:170])
PY
