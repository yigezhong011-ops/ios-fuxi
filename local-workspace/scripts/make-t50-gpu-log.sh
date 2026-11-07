#!/bin/bash
# t50-mine-gpu-fix plus the addon's cache-export switch, so the unified log reaches the UFS export region. Temporary boot only.
# Output: E:\DSH-Fuxi\t50-mine-gpu-log.img. The addon keeps its size; plugin code and trust cache do not change.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
BASE=/mnt/e/DSH-Fuxi/t50-mine-gpu-fix.img
OUT=/mnt/e/DSH-Fuxi/t50-mine-gpu-log.img
W=/root/fuxi/gpu-log; rm -rf "$W"; mkdir -p "$W"
export MTOOLS_SKIP_CHECK=1

bash "$S/verify-gpu-image.sh" "$BASE" >/dev/null 2>&1 || true
cp /root/fuxi/verify-img/vol.img "$W/vol.img"
cp /root/fuxi/verify-img/addon.bin "$W/addon-orig.bin"

python3 - "$W" <<'EOF'
import struct, sys, zlib
from pathlib import Path
w = Path(sys.argv[1])
blob = (w / 'addon-orig.bin').read_bytes()
pad8 = lambda n: n + (-n % 8)
count, _, _total = struct.unpack_from('<IIQ', blob, 8)
off, entries = 24, []
for _ in range(count):
    nlen, mode, size, csize = struct.unpack_from('<IIQQ', blob, off); off += 24
    name = blob[off:off + nlen - 1].decode(); off += pad8(nlen)
    entries.append((name, mode, size, blob[off:off + csize])); off += pad8(csize)
probe = next(e for e in entries if e[0] == 'bin/adrenoprobed')
raw = zlib.decompress(probe[3])
print('adrenoprobed', len(raw), 'zz-oslog' , raw.count(b'zz-oslog'))
if not raw.count(b'zz-oslog'):
    sys.exit('this adrenoprobed has no log writer')
kept = [e for e in entries if not e[0].startswith('addons/NativeAdrenoMetal.filler')]
data = b'1\n'
kept.insert(6, ('addons/NativeAdrenoMetal.cacheexport', 0o644, len(data), zlib.compress(data, 9)))
body = b''
for name, mode, size, packed in kept:
    enc = name.encode() + b'\0'
    body += struct.pack('<IIQQ', len(enc), mode, size, len(packed)) + enc + bytes(-len(enc) % 8) + packed + bytes(-len(packed) % 8)
(w / 'addon-new.bin').write_bytes(b'NGPUADD2' + struct.pack('<IIQ', len(kept), 0, 24 + len(body)) + body)
EOF

python3 "$S/fit-addon.py" "$W/addon-orig.bin" "$W/addon-new.bin" "$W/addon-fitted.bin"
python3 -I "$S/fat-inplace.py" "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon "$W/addon-fitted.bin"
mtype -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | cmp - "$W/addon-fitted.bin"
python3 -I "$S/repack-with-vol.py" "$BASE" "$W/vol.img" "$OUT"
python3 -I "$S/compare-loaders.py" "$OUT"
bash "$S/verify-gpu-image.sh" "$OUT" "$W/addon-fitted.bin" 2>&1 | tail -22 | cut -c1-110
cp /root/fuxi/verify-img/addon.bin "$W/addon-readback.bin"
cmp "$W/addon-readback.bin" "$W/addon-fitted.bin" && echo "addon readback matches"
python3 - "$BASE" "$OUT" <<'EOF'
import sys,zlib,struct
def body(p):
    d=open(p,'rb').read(); ks=struct.unpack_from('<I',d,8)[0]; hs=struct.unpack_from('<I',d,20)[0]; st=(hs+4095)//4096*4096
    return len(d), zlib.decompressobj(16+zlib.MAX_WBITS).decompress(d[st:st+ks])
a,x=body(sys.argv[1]); b,y=body(sys.argv[2])
n=sum(1 for i in range(0,min(len(x),len(y)),4096) if x[i:i+4096]!=y[i:i+4096])
print('image bytes',a,b,'inner',len(x),len(y),'differing 4K pages',n)
EOF
sha256sum "$OUT" | cut -c1-16
