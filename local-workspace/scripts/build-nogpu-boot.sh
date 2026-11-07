#!/bin/bash
# Diagnostic: boot the expert payload with the GPU arguments removed. A hard lock
# in the GPU path would then disappear, and the storage messages become visible.
set -euo pipefail
SRC=/mnt/e/DSH-Fuxi/unixnu-expert-boot.img
WORK=/root/fuxi/nogpu
OUT=/mnt/e/DSH-Fuxi/unixnu-expert-nogpu.img
M=$WORK/mnt
mkdir -p "$WORK" "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done

echo "=== 1) 取出专家镜像的 gzip 主体与设备树 ==="
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
print('  主体 %d 字节，设备树 %d 字节' % (len(body), len(un.unused_data)))
PY

echo "=== 2) 从主体里切出 payload 卷并挂载 ==="
python3 - "$WORK/body.bin" "$WORK/payload.img" <<'PY'
import struct, sys
body_path, out = sys.argv[1:3]
body = open(body_path, 'rb').read()
# FAT32 引导扇区：找 0x55AA 结尾且 0x52 处是 'FAT32'
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
if fat is None:
    raise SystemExit('没找到 FAT32 卷')
total = struct.unpack_from('<I', body, fat + 32)[0]
size = total * 512
open(out, 'wb').write(body[fat:fat + size])
print('  卷偏移 %d，大小 %.2f MiB' % (fat, size / 2**20))
PY

mount -t vfat -o loop,rw "$WORK/payload.img" "$M"
echo "=== 3) 修改 unixnu.toml（去掉 GPU 参数）==="
python3 - "$M/EFI/UniXNU/unixnu.toml" <<'PY'
import sys, re
p = sys.argv[1]
t = open(p, encoding='utf-8', errors='replace').read()
drop = ('sheng-gpu-metal=1', 'sheng-gpu-addon=1', 'sheng-gpu-dcvs=1',
        'sheng-fb-gpu=1', 'sheng-vsync=120', 'sheng-gpu-power=9')
before = t
for d in drop:
    t = t.replace(' ' + d, '').replace(d + ' ', '')
print('  删除了:', [d for d in drop if d in before])
open(p, 'w', encoding='utf-8').write(t)
print('  新 args 长度:', len(t))
PY
sync
umount "$M"

echo "=== 4) 重新打包 boot.img ==="
python3 - "$WORK/payload.img" "$WORK/body.bin" "$WORK/tree.dtb" "$WORK/Image.gz-dtb" <<'PY'
import gzip, sys
payload, body, tree, out = sys.argv[1:5]
data = open(body, 'rb').read()
# 主体 = 固件(shim+FV) + 旧 payload；用新 payload 替换旧部分
fat = None
for m in range(0, 8 << 20, 2):
    bs = data[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
firmware = data[:fat]
new = firmware + open(payload, 'rb').read()
blob = gzip.compress(new, mtime=0) + open(tree, 'rb').read()
open(out, 'wb').write(blob)
print('  固件 %d + 新负载 %d -> %d 字节' % (len(firmware), len(payload), len(blob)))
PY
printf '\0' > "$WORK/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$WORK/Image.gz-dtb" --ramdisk "$WORK/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o "$OUT" 2>&1 | tail -2
ls -lh "$OUT"
echo NOGPU_OK
