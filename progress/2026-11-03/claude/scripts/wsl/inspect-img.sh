#!/bin/bash
# What a new author image changes against t36: boot args, ADT identity and display props, and whether kernel / GPU addon /
# trust cache differ. Usage: inspect-img.sh <img> <workdir-name>
set -uo pipefail
export MTOOLS_SKIP_CHECK=1
IMG=$1; W=/root/fuxi/$2; rm -rf $W; mkdir -p $W
python3 -I - "$IMG" $W/vol.img <<'EOF'
import struct, sys, zlib
d = open(sys.argv[1], 'rb').read()
ks = struct.unpack_from('<I', d, 8)[0]
body = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(d[4096:4096 + ks])
base = next(b for b in range(0, 8 << 20, 2) if body[b + 0x52:b + 0x5a].startswith(b'FAT32') and body[b + 0x1fe:b + 0x200] == b'\x55\xaa')
open(sys.argv[2], 'wb').write(body[base:])
EOF
mtype -i $W/vol.img ::/EFI/UniXNU/unixnu.toml | grep -o 'args = "[^"]*"' | tr ' ' '\n' > $W/args.txt
mtype -i /root/fuxi/t36/vol.img ::/EFI/UniXNU/unixnu.toml | grep -o 'args = "[^"]*"' | tr ' ' '\n' > $W/args-t36.txt
echo "### args: t36 -> new"; diff $W/args-t36.txt $W/args.txt
mcopy -n -i $W/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.adt $W/new.adt
for n in /device-tree/product /device-tree/chosen; do
  python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py $n $W/new.adt | grep -E "model|product-name|artwork|display|compatible|target-type"
done
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree $W/new.adt | grep -E "^  (model|target-type) "
for f in kernel.macho kernel.macho.gpuaddon kernel.macho.trustcache; do
  mcopy -n -i $W/vol.img ::/EFI/UniXNU/Payloads/$f $W/$f 2>/dev/null
  cmp -s $W/$f /root/fuxi/t36/$f && echo "$f: same as t36" || echo "$f: DIFFERS ($(stat -c %s $W/$f) vs $(stat -c %s /root/fuxi/t36/$f))"
done
strings -n 20 $W/kernel.macho | grep -m1 'Darwin Kernel Version'
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/compare-loaders.py "$IMG" /mnt/e/DSH-Fuxi/t36-phone-cache-miss.img
