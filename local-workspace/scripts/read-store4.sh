#!/bin/bash
# Read-only: what the poster store holds now, and the next failure in the fresh log blocks.
A="python3 -I /mnt/e/DSH-Fuxi/dump/wsl/apfs-read.py /mnt/e/DSH-Fuxi/logs/data-raw.img"
C="mobile/Containers/Data/Application/353FB615-9AD2-407D-B79C-EFF255D5432B/Library/Application Support"
B="$C/PRBPosterExtensionDataStore/61"
$A ls 0 "$C/ArchivedDataStores" 2>&1 | tail -4 | cut -c1-100
echo "== extensions"; $A ls 0 "$B/Extensions" 2>&1 | tail -24 | cut -c1-110
echo "== GalleryCache"; $A ls 0 "$B/GalleryCache" 2>&1 | tail -6 | cut -c1-110
E="$B/Extensions/com.apple.PaperBoard.LegacyPoster"
echo "== LegacyPoster"; $A ls 0 "$E" 2>&1 | tail -8 | cut -c1-110
$A ls 0 "$E/staticdescriptors" 2>&1 | tail -6 | cut -c1-110
python3 -I - <<'PY'
import hashlib, re
from collections import Counter
def blocks(p):
    b = open(p, 'rb').read()
    m = list(re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b))
    for i, x in enumerate(m):
        yield int(x.group(1)), b[x.end():m[i + 1].start() if i + 1 < len(m) else len(b)]
old = {hashlib.sha1(c).digest() for _, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-storefix/lscan.txt')}
t = b'\n'.join(c for o, c in sorted(blocks('/mnt/e/DSH-Fuxi/logs/carve-storefix2/lscan.txt')) if hashlib.sha1(c).digest() not in old).decode('latin1')
L = [''.join(ch if 32 <= ord(ch) < 127 else '.' for ch in l) for l in t.split('\n')]
N = lambda l: re.sub(r'0x[0-9a-f]+|[0-9A-Fa-f]{8}-[0-9A-Fa-f-]{27}|\d+', '#', l)[:165]
c = Counter()
for l in L:
    if re.search(r'(?i)poster|wallpaper|PBF|PRS|PBUI|Aegir|Collections', l) and re.search(r'(?i)error|fail|could not|unable|invalid|nil|crash|abort|exit|terminat|kill|denied|deny|not found|missing|timeout|timed out', l) and not l.startswith('file://'):
        c[N(l)] += 1
print('== poster and wallpaper failures, fresh blocks')
for k, v in c.most_common(45): print(v, k)
c = Counter()
for l in L:
    if re.search(r'(?i)wallpaper|poster', l) and re.search(r'(?i)default|selected|active|configuration|snapshot|render|updat|complete|finish', l) and not l.startswith('file://') and 'failure' not in l:
        c[N(l)] += 1
print('== progress messages')
for k, v in c.most_common(30): print(v, k)
PY
D=$(python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode /mnt/e/DSH-Fuxi/logs/carve-storefix2/log.bin --out /root/fuxi/hang/storefix2 2>&1 | tail -1 | cut -d: -f1)
echo "== kernel log $D"; sed -n 1p "$D/latest.txt" | cut -c1-80
grep -a -o -E '.{0,60}(PosterBoard|Poster|AegirPoster)[^ ]{0,20}.{0,20}(exit|signal|jetsam|killed|crash|EXC_|sig [0-9]+|memorystatus).{0,70}' "$D/msgbuf.txt" | head -14 | cut -c1-170
grep -a -c -E 'EXITCRASH|Process .* (crash|exit)' "$D/msgbuf.txt"
grep -a -E '^\[(gpu clients|gpu client|coherence)\]' "$D/latest.txt" | cut -c1-200 | head -6
