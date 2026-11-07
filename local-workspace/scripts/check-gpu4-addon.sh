#!/bin/bash
# Pull the GPU addon out of t32-gpu4.img's payload volume and print its client list.
set -euo pipefail
W=/root/fuxi/chk-gpu4; mkdir -p $W
python3 -I - <<'EOF'
import struct, zlib
data = open('/mnt/e/DSH-Fuxi/t32-gpu4.img', 'rb').read()
ksize = struct.unpack_from('<I', data, 8)[0]
body = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(data[4096:4096 + ksize])
vol = open('/root/fuxi/t32/vol.img', 'rb').read(512)
base = body.find(vol)
open('/root/fuxi/chk-gpu4/vol.img', 'wb').write(body[base:base + 0xb000000])
EOF
mcopy -n -i $W/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon $W/addon
ls -l $W/addon /root/fuxi/t32/kernel.macho.gpuaddon /root/fuxi/t32/addon-t32-gpu4
cmp $W/addon /root/fuxi/t32/addon-t32-gpu4 && echo "addon in image == addon-t32-gpu4"
python3 -I - <<'EOF'
import struct, zlib
d = open('/root/fuxi/chk-gpu4/addon', 'rb').read()
n = struct.unpack_from('<I', d, 8)[0]; off = 24
for _ in range(n):
    nl, mode, size, cs = struct.unpack_from('<IIQQ', d, off); off += 24
    name = d[off:off + nl - 1].decode(); off += nl + (-nl % 8)
    if name.endswith('.clients'):
        print('clients:', zlib.decompress(d[off:off + cs]).decode().split()[:8])
    off += cs + (-cs % 8)
EOF
