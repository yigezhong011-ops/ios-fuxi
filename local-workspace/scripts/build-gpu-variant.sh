#!/bin/bash
# Bisect the GPU arguments: build a boot image from the expert payload with only
# the GPU switches named on the command line re-enabled.
#   build-gpu-variant.sh "arg1 arg2" out.img
set -euo pipefail
KEEP=${1:?用法: build-gpu-variant.sh "参数..." out.img}
OUT=${2:?用法: build-gpu-variant.sh "参数..." out.img}
SRC=/mnt/e/DSH-Fuxi/unixnu-expert-boot.img
WORK=/root/fuxi/variant
M=$WORK/mnt
mkdir -p "$WORK" "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done

# 1) 取出 gzip 主体与设备树
python3 - "$SRC" "$WORK/body.bin" "$WORK/tree.dtb" <<'PY'
import struct, sys, zlib
src, body_out, tree_out = sys.argv[1:4]
d = open(src, 'rb').read()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
open(body_out, 'wb').write(body)
open(tree_out, 'wb').write(un.unused_data)
PY

# 2) 切出 payload 卷
python3 - "$WORK/body.bin" "$WORK/payload.img" <<'PY'
import struct, sys
body = open(sys.argv[1], 'rb').read()
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
open(sys.argv[2], 'wb').write(body[fat:fat + total * 512])
print('  payload 卷 %d 字节 @ %d' % (total * 512, fat))
PY

# 3) 改 toml：先删掉全部 GPU 参数，再把 KEEP 加回去
mount -t vfat -o loop,rw "$WORK/payload.img" "$M"
python3 - "$M/EFI/UniXNU/unixnu.toml" "$KEEP" <<'PY'
import sys
p, keep = sys.argv[1], sys.argv[2]
t = open(p, encoding='utf-8', errors='replace').read()
all_gpu = ('sheng-gpu-metal=1', 'sheng-gpu-addon=1', 'sheng-gpu-dcvs=1',
           'sheng-fb-gpu=1', 'sheng-vsync=120', 'sheng-gpu-power=9')
for g in all_gpu:
    t = t.replace(' ' + g, '').replace(g + ' ', '')
if keep.strip():
    t = t.replace('args = "', 'args = "%s ' % keep.strip(), 1)
open(p, 'w', encoding='utf-8').write(t)
print('  保留的 GPU 参数:', keep.strip() or '（无）')
PY
sync
umount "$M"

# 4) 重新打包
python3 - "$WORK/payload.img" "$WORK/body.bin" "$WORK/tree.dtb" "$WORK/Image.gz-dtb" <<'PY'
import gzip, sys
payload, body_path, tree, out = sys.argv[1:5]
body = open(body_path, 'rb').read()
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
blob = gzip.compress(body[:fat] + open(payload, 'rb').read(), mtime=0) + open(tree, 'rb').read()
open(out, 'wb').write(blob)
PY
printf '\0' > "$WORK/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$WORK/Image.gz-dtb" --ramdisk "$WORK/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o "$OUT" 2>&1 | tail -1
ls -lh "$OUT"
echo VARIANT_OK
