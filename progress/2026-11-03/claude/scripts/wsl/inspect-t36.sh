#!/bin/bash
# What the t32 author's iOS-layout image t36 changes against t32: payload files, boot args, ADT identity.
set -uo pipefail
export MTOOLS_SKIP_CHECK=1
IMG=/mnt/e/DSH-Fuxi/t36-phone-cache-miss.img
W=/root/fuxi/t36; rm -rf $W; mkdir -p $W
python3 -I - "$IMG" $W/vol.img <<'EOF'
import struct, sys, zlib
d = open(sys.argv[1], 'rb').read()
print('magic', d[:8], 'header v', struct.unpack_from('<I', d, 40)[0])
ks = struct.unpack_from('<I', d, 8)[0]
body = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(d[4096:4096 + ks])
at = body.find(b'FUXIESP')
base = body.rfind(b'\xeb', 0, at)  # FAT boot sector jump before the volume label
for cand in range(max(0, at - 0x60), at):
    if body[cand] in (0xeb, 0xe9) and body[cand + 510:cand + 512] == b'\x55\xaa':
        base = cand; break
open(sys.argv[2], 'wb').write(body[base:])
print('volume at', hex(base), 'bytes', len(body) - base)
EOF
mdir -/ -i $W/vol.img ::/EFI/UniXNU | grep -iE 'toml|macho|trust|gpu|adt|img'
mtype -i $W/vol.img ::/EFI/UniXNU/unixnu.toml | grep -o 'args = "[^"]*"' | tr ' ' '\n' > $W/args.txt
mtype -i /root/fuxi/t32/vol.img ::/EFI/UniXNU/unixnu.toml | grep -o 'args = "[^"]*"' | tr ' ' '\n' > $W/args-t32.txt
echo "### args: t32 -> t36"; diff $W/args-t32.txt $W/args.txt
mcopy -n -i $W/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.adt $W/t36.adt
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree/product $W/t36.adt | head -14
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree $W/t36.adt | grep -E "model|target-type|compatible" | head -5
for f in kernel.macho kernel.macho.gpuaddon kernel.macho.trustcache; do
  mcopy -n -i $W/vol.img ::/EFI/UniXNU/Payloads/$f $W/$f 2>/dev/null
  cmp -s $W/$f /root/fuxi/t32/$f && echo "$f: same as t32" || echo "$f: differs ($(stat -c %s $W/$f) vs $(stat -c %s /root/fuxi/t32/$f))"
done
