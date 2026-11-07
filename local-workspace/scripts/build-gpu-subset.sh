#!/bin/bash
# Build the one GPU combination never tried: addon + fb-gpu (no Metal), plus a
# second variant with the clocks it needs.
#   build-gpu-subset.sh "<extra args>" out.img [trustcache-from]
set -euo pipefail
EXTRA=${1:?参数}
OUT=${2:?输出}
TC=${3:-}
SRC=/mnt/e/DSH-Fuxi/unixnu-expert-boot.img
W=/root/fuxi/sub
M=$W/mnt
mkdir -p "$W" "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done

python3 - "$SRC" "$W/body.bin" "$W/tree.dtb" "$W/payload.img" <<'PY'
import struct, sys, zlib
src, body_out, tree_out, payload_out = sys.argv[1:5]
d = open(src, 'rb').read()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
open(body_out, 'wb').write(body)
open(tree_out, 'wb').write(un.unused_data)
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
open(payload_out, 'wb').write(body[fat:fat + total * 512])
PY

mount -t vfat -o loop,rw "$W/payload.img" "$M"
python3 - "$M/EFI/UniXNU/unixnu.toml" "$EXTRA" <<'PY'
import re, sys
p, extra = sys.argv[1], sys.argv[2]
t = open(p, encoding='utf-8', errors='replace').read()
for g in ('sheng-gpu-metal=1', 'sheng-fb-gpu=1', 'sheng-gpu-addon=1',
          'sheng-gpu-dcvs=1', 'sheng-vsync=120', 'sheng-gpu-power=9'):
    t = t.replace(' ' + g, '').replace(g + ' ', '')
t = t.replace('args = "', 'args = "%s ' % extra.strip(), 1)
open(p, 'w', encoding='utf-8').write(t)
m = re.search(r'args = "([^"]*)"', t)
print('  GPU 参数:', ' '.join(w for w in m.group(1).split() if 'gpu' in w or 'vsync' in w) or '（无）')
PY
if [ -n "$TC" ]; then
  cp "$TC" "$M/EFI/UniXNU/Payloads/kernel.macho.trustcache"
  echo "  trustcache 换成 $TC"
fi
sync
umount "$M"

python3 - "$W/payload.img" "$W/body.bin" "$W/tree.dtb" "$W/Image.gz-dtb" <<'PY'
import gzip, struct, sys
payload, body_path, tree, out = sys.argv[1:5]
body = open(body_path, 'rb').read()
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
open(out, 'wb').write(gzip.compress(body[:fat] + open(payload, 'rb').read(), mtime=0) + open(tree, 'rb').read())
PY
printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o "$OUT" 2>&1 | tail -1
ls -lh "$OUT"
