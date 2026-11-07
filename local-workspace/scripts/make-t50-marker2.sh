#!/bin/bash
# t50-auto-hanghigh plus ten progress bands along the loader's first steps. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl; E=/mnt/e/DSH-Fuxi
tr -d '\r' < $S/patch-loader-marker2.py > /tmp/plm2.py
python3 -I /tmp/plm2.py $E/t50-auto-hanghigh.img $E/t50-auto-marker2.img
dis() { aarch64-linux-gnu-objdump -D -b binary -m aarch64 --start-address=$1 --stop-address=$2 /tmp/marker2-body.bin | tail -n +8 | cut -c1-72; }
echo '--- hooks'
for s in 0x4 0xac 0xc0 0x790d4 0x79174 0x2140 0x2198 0x2434 0x2acc 0x3308; do dis $s $(($s + 4)); done
echo '--- context of the two stack-saving sites in the original'
python3 -I - <<'PY'
import struct, zlib
d = open('/mnt/e/DSH-Fuxi/t50-auto-hanghigh.img', 'rb').read()
k = struct.unpack_from('<I', d, 8)[0]
b = zlib.decompressobj(31).decompress(d[4096:4096 + k])
open('/tmp/ldr.bin', 'wb').write(b[:0x3000c0])
PY
aarch64-linux-gnu-objdump -D -b binary -m aarch64 --start-address=0x2ac0 --stop-address=0x2adc /tmp/ldr.bin | tail -n +8 | cut -c1-72
aarch64-linux-gnu-objdump -D -b binary -m aarch64 --start-address=0x32fc --stop-address=0x3318 /tmp/ldr.bin | tail -n +8 | cut -c1-72
echo '--- caves'
dis 0x2f0000 0x2f0200
python3 -I - <<'PY'
import struct, zlib
def body(p):
    d = open(p, 'rb').read(); k = struct.unpack_from('<I', d, 8)[0]
    o = zlib.decompressobj(31); b = o.decompress(d[4096:4096 + k]); return b, o.unused_data, d
a, ad, _ = body('/mnt/e/DSH-Fuxi/t50-auto-hanghigh.img'); b, bd, d = body('/mnt/e/DSH-Fuxi/t50-auto-marker2.img')
diff = [i for i in range(len(a)) if a[i] != b[i]] if len(a) == len(b) else None
print('lengths', len(a), len(b), 'dtb same', ad == bd, 'bytes differ', len(diff))
print('outside hooks and cave:', [hex(i) for i in diff if not (0x2f0000 <= i < 0x2f0800) and (i & ~3) not in (4, 0xac, 0xc0, 0x790d4, 0x79174, 0x2140, 0x2198, 0x2434, 0x2acc, 0x3308)][:8])
print('image size', len(d), 'page aligned', len(d) % 4096 == 0)
PY
sha256sum $E/t50-auto-marker2.img | cut -c1-16
