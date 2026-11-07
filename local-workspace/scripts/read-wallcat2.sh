#!/bin/bash
# Read-only: did this boot pass the catalogue gate, and what fails next. Fresh blocks against the storefix2 capture.
E=/mnt/e/DSH-Fuxi
grep -a -E 'RESULT|HELLO OK|BACK in|=== try' $E/logs/chain-wallcat.log | cut -c1-140
python3 -I - <<'PY'
import hashlib, re
from collections import Counter
def blocks(p):
    b = open(p, 'rb').read()
    m = list(re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b))
    for i, x in enumerate(m):
        yield int(x.group(1)), b[x.end():m[i + 1].start() if i + 1 < len(m) else len(b)]
old = {hashlib.sha1(c).digest() for _, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-storefix2/lscan.txt')}
new = [(o, c) for o, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-wallcat/lscan.txt') if hashlib.sha1(c).digest() not in old]
t = b'\n'.join(c for o, c in sorted(new)).decode('latin1')
print('fresh blocks', len(new), 'bytes', len(t))
for p in ('Collections.plist', 'does not contain valid value', 'Data store could not be created', 'not trusted', 'exited due to SIGABRT', 'Terminating app', 'DefaultWallpapers', 'D4894D14', 'Bokeh', '5010', 'jetsam', 'ActiveHard', 'per-process-limit', 'AGXDeviceUserClient', 'AdrenoMetal', 'MTLCreateSystemDefaultDevice', 'newTextureLayout', 'OutOfMemory', 'snapshot'):
    print('%7d %s' % (t.count(p), p))
L = [''.join(ch if 32 <= ord(ch) < 127 else '.' for ch in l) for l in t.split('\n')]
N = lambda l: re.sub(r'0x[0-9a-f]+|[0-9A-Fa-f]{8}-[0-9A-Fa-f-]{27}|\d+', '#', l)[:190]
def top(title, f, n):
    c = Counter(N(l) for l in L if f(l))
    print('==', title)
    for k, v in c.most_common(n): print(v, k)
top('exceptions and aborts', lambda l: re.search(r'Terminating app|uncaught|exited due to|Assertion failed|fatal|EXC_', l) and re.search(r'(?i)poster|wallpaper|Collections|PBF|PRS', l), 25)
top('Bokeh and defaults', lambda l: re.search(r'Bokeh|D4894D14|DefaultWallpapers|defaultWallpaper|WKDefault|WKWallpaper', l) and not re.search(r'^(file:)?/+Library/Wallpaper/Collections/.*\.wallpaper/?$', l), 30)
top('errors on poster paths', lambda l: re.search(r'(?i)error|fail|could not|unable|not found', l) and re.search(r'(?i)poster|wallpaper|PBF|PRS|PBUI|CollectionsPoster', l) and 'PRPosterConfigurableOptions' not in l and 'Sandbox:' not in l and not l.startswith('file:'), 35)
top('sandbox denials', lambda l: l.startswith('Sandbox:') and re.search(r'Poster|poster', l), 15)
PY
D=$(python3 -I $E/unixnu-build/fuxi/scripts/read-sheng-log.py --decode $E/logs/carve-wallcat/log.bin --out /root/fuxi/hang/wallcat 2>&1 | tail -1 | cut -d: -f1)
echo "== kernel log $D"; sed -n 1p "$D/latest.txt" | cut -c1-80
grep -a -E '^\[(gpu clients|coherence|addon|gpu addon)\]|addon3|native_gpu_addon' "$D/latest.txt" | cut -c1-700 | head -6
grep -a -o -E '.{0,80}(PosterBoard|CollectionsPoster).{0,100}' "$D/msgbuf.txt" | grep -a -i -E 'exit|jetsam|kill|memorystatus|crash|sig' | head -12 | cut -c1-190
