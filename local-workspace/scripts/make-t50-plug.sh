#!/bin/bash
# A gesture test image from t50-gpu7 with another plugin build merged into the addon, plus the longer grant.
# The wallpaper entries stay. New entry names are dropped (gpu-build.json is only build information). Temp boot only.
# Usage: [AUTO_CORES=0xf9] make-t50-plug.sh <plugin dir> <out name>
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
P=$1; OUT=$2
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; B=/root/fuxi/t50-gpu7; W=/root/fuxi/plug-$OUT
rm -rf "$W"; mkdir -p "$W"; cd "$W"
cp "$B/vol.img" vol.img; cp "$B/kernel.macho" kernel.macho
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon > addon-cur.bin
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.trustcache > trust-cur.bin
python3 -I - addon-cur.bin "$P/gpuaddon.bin" addon-merged.bin <<'EOF'
import struct, sys, zlib
def pad8(n): return n + (-n % 8)
def parse(p):
    b = open(p, 'rb').read(); c = struct.unpack_from('<I', b, 8)[0]; at = 24; r = []
    for _ in range(c):
        nl, m, s, pk = struct.unpack_from('<IIQQ', b, at); at += 24
        n = b[at:at + nl - 1].decode(); at += pad8(nl)
        r.append([n, m, s, b[at:at + pk]]); at += pad8(pk)
    return r
cur, new = parse(sys.argv[1]), {e[0]: e for e in parse(sys.argv[2])}
names = {e[0] for e in cur}
extra = sorted(set(new) - names)
print('dropped new entries', extra)
assert all(n.endswith('/gpu-build.json') for n in extra), extra
out, swapped = [], 0
for e in cur:
    if '.filler' in e[0]:
        continue
    if e[0] in new and new[e[0]][3] != e[3]:
        swapped += 1
        print('swap', e[0], e[2], '->', new[e[0]][2])
        e = new[e[0]]
    assert len(zlib.decompress(e[3])) == e[2], e[0]
    out.append(e)
body = b''
for n, m, s, pk in out:
    enc = n.encode() + b'\0'
    body += struct.pack('<IIQQ', len(enc), m, s, len(pk)) + enc + bytes(-len(enc) % 8) + pk + bytes(-len(pk) % 8)
open(sys.argv[3], 'wb').write(b'NGPUADD2' + struct.pack('<IIQ', len(out), 0, 24 + len(body)) + body)
print('entries', len(cur), '->', len(out), 'swapped', swapped, 'bytes', 24 + len(body))
EOF
python3 -I $S/fit-addon.py addon-cur.bin addon-merged.bin addon-fitted.bin
[ "$(stat -c %s addon-fitted.bin)" = "$(stat -c %s addon-cur.bin)" ]
python3 -I $S/patch-trustcache.py trust-cur.bin "$P/cdhashes.txt" trust-new.bin | tail -2
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon addon-fitted.bin >/dev/null
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho.trustcache trust-new.bin >/dev/null
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | cmp - addon-fitted.bin
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.trustcache | cmp - trust-new.bin
tr -d '\r' < $S/make-t50-grant.sh > /tmp/make-t50-grant-$OUT.sh
bash /tmp/make-t50-grant-$OUT.sh "$W" "$OUT"
ls -la $E/$OUT.img; sha256sum $E/$OUT.img | cut -c1-16
cat "$P/art/gpu-build.json" 2>/dev/null | head -30 || true
cat "$P/revisions.txt"
