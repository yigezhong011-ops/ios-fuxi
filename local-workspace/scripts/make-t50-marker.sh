#!/bin/bash
# t50-auto-hanghigh plus a red band at the loader's entry. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl; E=/mnt/e/DSH-Fuxi
tr -d '\r' < $S/patch-loader-marker.py > /tmp/plm.py
python3 -I /tmp/plm.py $E/t50-auto-hanghigh.img $E/t50-auto-marker.img
llvm-objdump -D -b binary -m aarch64 /tmp/marker-code.bin 2>/dev/null | tail -n +7 | cut -c1-70 || true
python3 - <<'PY'
import struct, zlib
def body(p):
    d = open(p, 'rb').read(); k = struct.unpack_from('<I', d, 8)[0]
    o = zlib.decompressobj(31); b = o.decompress(d[4096:4096 + k]); return b, o.unused_data, d
a, ad, _ = body('/mnt/e/DSH-Fuxi/t50-auto-hanghigh.img'); b, bd, d = body('/mnt/e/DSH-Fuxi/t50-auto-marker.img')
diff = [i for i in range(len(a)) if a[i] != b[i]] if len(a) == len(b) else None
print('lengths', len(a), len(b), 'dtb same', ad == bd, 'bytes differ', len(diff), 'range', hex(diff[0]), hex(diff[-1]))
print('outside entry and cave:', [hex(i) for i in diff if not (i < 8 or 0x2f0000 <= i < 0x2f0100)][:8])
print('image size', len(d), 'page aligned', len(d) % 4096 == 0)
PY
sha256sum $E/t50-auto-marker.img | cut -c1-16
