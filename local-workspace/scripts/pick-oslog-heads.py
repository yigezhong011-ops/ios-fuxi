#!/usr/bin/env python3
"""Which gzip heads are the sheng oslog? Usage: pick-oslog-heads.py <scan.txt> <heads.bin> <list out>   Second mode: --list <scan.txt> <list out>"""
import re
import sys
import zlib

if sys.argv[1] == '--list':
    rows = re.findall(r'GZ rel=\d+ abs=(\d+) flags=0 os=(\d+)', open(sys.argv[2]).read())
    open(sys.argv[3], 'w', newline='\n').write(''.join(a + '\n' for a, o in rows if o == '19'))
    print('gzip heads', len(rows), 'written by Darwin zlib', sum(o == '19' for _, o in rows))
    sys.exit(0)
rows = [a for a, o in re.findall(r'GZ rel=\d+ abs=(\d+) flags=0 os=(\d+)', open(sys.argv[1]).read()) if o == '19']
heads = open(sys.argv[2], 'rb').read()
hits = []
for i, a in enumerate(rows):
    d = zlib.decompressobj(16 + zlib.MAX_WBITS)
    try:
        t = d.decompress(heads[i * 4096:(i + 1) * 4096])
    except zlib.error:
        continue
    m = re.match(rb'# sheng oslog pass (\d+)', t)
    if m:
        hits.append((a, int(m[1])))
open(sys.argv[3], 'w', newline='\n').write(''.join(f'{a}\n' for a, _ in hits))
print('oslog heads', len(hits), hits[:40])
