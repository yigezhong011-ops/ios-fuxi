#!/bin/bash
# Reproduce what uefi-fuxi/scripts/bootimage.py does, reusing the firmware we
# already know boots on this device (BACKUP-ufs-works.img holds gzip(shim+FD)):
#   kernel = gzip(shim + firmware + payload) + device tree
#   ramdisk = one byte placeholder
set -euo pipefail
WORK=/root/fuxi/unixnu
UEFI=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
PAYLOAD=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/payload/payload.img
DTB=$UEFI/Resources/DTBs/fuxi.dtb
OUT=/mnt/e/DSH-Fuxi/unixnu-fuxi-official.img

ls -l "$PAYLOAD" "$DTB"

echo "=== 1) 解压既有固件的 gzip 内核 ==="
python3 - "$WORK/uefi.img" "$WORK/fw_combined.bin" <<'PY'
import gzip, sys
src, dst = sys.argv[1], sys.argv[2]
raw = gzip.decompress(open(src, 'rb').read())
open(dst, 'wb').write(raw)
print('  gzip 解出 %d 字节（shim + 固件卷）' % len(raw))
PY

echo "=== 2) 拼 payload 并重新 gzip，末尾接设备树 ==="
python3 - "$WORK/fw_combined.bin" "$PAYLOAD" "$DTB" "$WORK/Image.gz-dtb" <<'PY'
import gzip, sys
fw, payload, dtb, out = sys.argv[1:5]
combined = open(fw, 'rb').read() + open(payload, 'rb').read()
tree = open(dtb, 'rb').read()
if tree[:4] != b'\xd0\x0d\xfe\xed':
    raise SystemExit('设备树不是 FDT')
blob = gzip.compress(combined, mtime=0) + tree
open(out, 'wb').write(blob)
print('  combined %d + dtb %d -> %d 字节' % (len(combined), len(tree), len(blob)))
PY

echo "=== 3) 打包 v4（ramdisk 占位 1 字节）==="
printf '\0' > "$WORK/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py \
  --header_version 4 --pagesize 4096 \
  --kernel "$WORK/Image.gz-dtb" --ramdisk "$WORK/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 \
  -o "$OUT" 2>&1 | tail -3
ls -lh "$OUT"

echo "=== 4) 校验（对照 bootimage.py 的 verify）==="
python3 - "$OUT" "$WORK/fw_combined.bin" "$PAYLOAD" "$DTB" <<'PY'
import struct, sys, zlib
img, fw, payload, dtb = sys.argv[1:5]
d = open(img, 'rb').read()
assert d[:8] == b'ANDROID!'
ksize, rsize, _, hsize = struct.unpack_from('<4I', d, 8)
ver = struct.unpack_from('<I', d, 40)[0]
print('  header v%d  kernel=%d  ramdisk=%d  header_size=%d' % (ver, ksize, rsize, hsize))
page = 4096
kernel = d[page:page + ksize]
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(kernel)
tree = open(dtb, 'rb').read()
expect = open(fw, 'rb').read() + open(payload, 'rb').read()
print('  gzip 内容一致:', body == expect)
print('  gzip 结束:', un.eof, ' 尾部设备树一致:', un.unused_data == tree)
PY
echo BOOTIMAGE_OK
