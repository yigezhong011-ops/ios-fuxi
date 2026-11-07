#!/bin/bash
# Why did no sheng oslog land in Data? Source, addon contents, the boot log and the carved gzip heads. Read-only.
M=/root/fuxi/src-adrenometal
echo "== source"
cat -n $M/NativeOsLogExport.mm | cut -c1-150 | head -130
echo "== callers"
grep -rn -E 'nativeOsLogExport|NativeOsLogExport' $M --include=*.mm --include=*.h --include=*.cpp | cut -c1-160 | head
echo "== probe daemon sources"
grep -rln -E 'adrenoprobed' $M /mnt/e/DSH-Fuxi/unixnu-build/fuxi 2>/dev/null | head
echo "== boot log mentions"
L=$(ls -d /root/fuxi/log-oslog1/*/ | head -1); echo "$L"; ls -la "$L" | cut -c1-90 | head -20
python3 -I - "$L" <<'EOF'
import re, sys
from collections import Counter
from pathlib import Path
d = Path(sys.argv[1])
for f in d.iterdir():
    if not f.is_file():
        continue
    s = f.read_bytes().replace(b'\0', b'').decode('latin1')
    for pat in ('adrenoprobed', 'oslog', 'OSLogStore|OSLog', 'zz-oslog', 'blu-sharky'):
        hits = re.findall(r'[ -~]{0,90}(?:%s)[ -~]{0,120}' % pat, s)
        if hits:
            print('--', f.name, pat, len(hits))
            for k, v in Counter(re.sub(r'\[ *[\d.]+\]:?|\[\d+\]|\(\d+\)|0x[0-9a-f]+', '', h)[:200] for h in hits).most_common(6):
                print(f'   {v:4d} {k}')
EOF
echo "== carved heads"
python3 -I - <<'EOF'
import re, zlib
base = '/mnt/e/DSH-Fuxi/logs/carve-tonight/'
rows = [(int(r), a) for r, a, o in re.findall(r'GZ rel=(\d+) abs=(\d+) flags=0 os=(\d+)', open(base + 'scan.txt').read()) if o == '19']
heads = open(base + 'heads.bin', 'rb').read()
for i, (r, a) in enumerate(rows):
    d = zlib.decompressobj(16 + zlib.MAX_WBITS)
    try:
        t = d.decompress(heads[i * 4096:(i + 1) * 4096])
    except zlib.error as e:
        t = b'<' + str(e).encode() + b'>'
    print(r, a, len(t), repr(t[:70]))
EOF
