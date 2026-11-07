#!/bin/bash
# Build the UniXNU fuxi boot image: the UEFI firmware as the kernel and the
# FAT32 payload volume as the ramdisk (board.toml: "[payload] the ramdisk of
# the boot image").
set -euo pipefail
SRC=/mnt/c/Users/USER/Downloads/BACKUP-ufs-works.img
PAYLOAD=/mnt/e/DSH-Fuxi/unixnu-fuxi/fuxi/payload/payload.img
OUT=/mnt/e/DSH-Fuxi/unixnu-fuxi-boot.img
WORK=/root/fuxi/unixnu
MKBOOTIMG=/mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py

mkdir -p "$WORK"
echo "=== 1) 从备份镜像里取出 UEFI ==="
python3 - "$SRC" "$WORK/uefi.img" <<'PY'
import struct, sys
src, dst = sys.argv[1], sys.argv[2]
d = open(src, 'rb').read()
assert d[:8] == b'ANDROID!'
ksize = struct.unpack_from('<I', d, 8)[0]
hsize = struct.unpack_from('<I', d, 20)[0]
rsize = struct.unpack_from('<I', d, 12)[0]
hver = struct.unpack_from('<I', d, 40)[0]
print('header_version=%d kernel_size=%d ramdisk_size=%d header_size=%d' % (hver, ksize, rsize, hsize))
page = 4096 if hver >= 3 else struct.unpack_from('<I', d, 36)[0]
start = (hsize + page - 1) // page * page
k = d[start:start + ksize]
print('UEFI 段 %d 字节，前 16: %s' % (len(k), k[:16].hex()))
open(dst, 'wb').write(k)
PY
ls -l "$WORK/uefi.img"

echo "=== 2) 打包：UEFI + payload ramdisk（v4）==="
python3 "$MKBOOTIMG" --header_version 4 \
  --kernel "$WORK/uefi.img" \
  --ramdisk "$PAYLOAD" \
  --os_version 16.0.0 --os_patch_level 2026-08 \
  -o "$OUT"
ls -lh "$OUT"
echo "=== 3) 校验打包结果 ==="
python3 - "$OUT" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read(2400)
print('magic', d[:8])
ksize, rsize, osver, hsize = struct.unpack_from('<IIII', d, 8)
hver = struct.unpack_from('<I', d, 40)[0]
print('kernel_size=%d ramdisk_size=%d header_size=%d header_version=%d' % (ksize, rsize, hsize, hver))
PY
echo UNIXNU_BOOT_OK
