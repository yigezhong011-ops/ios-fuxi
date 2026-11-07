#!/bin/bash
# Read-only: the Collections.plist exception in full, the "not trusted" context, and which plists exist locally.
python3 -I - <<'PY'
import re
from collections import Counter
b = open('/mnt/e/DSH-Fuxi/logs/carve-storefix2/lscan.txt', 'rb').read()
seen = Counter()
for m in re.finditer(rb"WKWallpaperRepresentingCollectionsManager: [^\n]{0,600}", b):
    seen[m.group(0).decode('latin1')] += 1
print('== collections exception')
for k, v in seen.most_common(6): print(v, k)
print('== Collections words')
c = Counter(x.decode('latin1') for x in re.findall(rb'/Library/Wallpaper[ -~]{0,100}', b))
for k, v in c.most_common(25): print(v, k)
print('== not trusted context')
i = b.find(b'"not trusted"')
n = 0
while i >= 0 and n < 3:
    print(b[max(0, i - 500):i + 160].decode('latin1').encode('ascii', 'replace').decode()); print('-----')
    i = b.find(b'"not trusted"', i + 200000); n += 1
PY
echo '== local plists'
find /mnt/e/DSH-Fuxi/ngpu/wallpaper -maxdepth 3 2>/dev/null | head -30
find /mnt/e/DSH-Fuxi/read /mnt/e/DSH-Fuxi/dump -maxdepth 4 -iname '*Collections*plist*' 2>/dev/null | head -20
echo '== doc mentions'
grep -rIl --include='*.md' -E 'Collections\.plist|WKWallpaperRepresenting' /mnt/e/DSH-Fuxi/read /mnt/e/DSH-Fuxi/unixnu-build/fuxi 2>/dev/null | head
grep -rIn --include='*.md' -E 'Collections\.plist|WKWallpaperRepresenting' /mnt/e/DSH-Fuxi/read 2>/dev/null | head -20 | cut -c1-260
