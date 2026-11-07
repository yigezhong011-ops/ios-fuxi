#!/bin/bash
# Build the fuxi boot image the way uefi-fuxi/scripts/bootimage.py does, reusing
# the firmware that already boots here:
#   field = gzip(shim + firmware + payload) + device tree
#   ramdisk = one byte placeholder
set -euo pipefail
WORK=/root/fuxi/unixnu
PAYLOAD=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/payload/payload.img
OUT=${1:-/mnt/e/DSH-Fuxi/unixnu-fuxi-official.img}

echo "=== 1) 拆出固件 gzip 主体与尾部设备树 ==="
python3 - "$WORK/uefi.img" "$WORK/fw_combined.bin" "$WORK/tree.dtb" <<'PY'
import sys, zlib
src, body_out, tree_out = sys.argv[1:4]
data = open(src, 'rb').read()
d = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = d.decompress(data)
if not d.eof:
    raise SystemExit('gzip 流没有正常结束')
tree = d.unused_data
print('  固件主体 %d 字节，尾部设备树 %d 字节' % (len(body), len(tree)))
if tree[:4] != b'\xd0\x0d\xfe\xed':
    raise SystemExit('尾部不是 FDT')
open(body_out, 'wb').write(body)
open(tree_out, 'wb').write(tree)
PY

echo "=== 2) 拼 payload，重新 gzip，尾部接设备树 ==="
python3 - "$WORK/fw_combined.bin" "$PAYLOAD" "$WORK/tree.dtb" "$WORK/Image.gz-dtb" <<'PY'
import gzip, sys
fw, payload, tree, out = sys.argv[1:5]
combined = open(fw, 'rb').read() + open(payload, 'rb').read()
blob = gzip.compress(combined, mtime=0) + open(tree, 'rb').read()
open(out, 'wb').write(blob)
print('  combined %d -> 压缩后 %d 字节' % (len(combined), len(blob)))
PY

echo "=== 3) 打包 v4 + 1 字节 ramdisk ==="
printf '\0' > "$WORK/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py \
  --header_version 4 --pagesize 4096 \
  --kernel "$WORK/Image.gz-dtb" --ramdisk "$WORK/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 \
  -o "$OUT" 2>&1 | tail -2
ls -lh "$OUT"

echo "=== 4) 校验 ==="
python3 - "$OUT" "$WORK/fw_combined.bin" "$PAYLOAD" "$WORK/tree.dtb" <<'PY'
import struct, sys, zlib
img, fw, payload, tree = sys.argv[1:5]
d = open(img, 'rb').read()
assert d[:8] == b'ANDROID!'
ksize, rsize, _, hsize = struct.unpack_from('<4I', d, 8)
ver = struct.unpack_from('<I', d, 40)[0]
print('  header v%d kernel=%d ramdisk=%d' % (ver, ksize, rsize))
page = 4096
kernel = d[page:page + ksize]
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(kernel)
expect = open(fw, 'rb').read() + open(payload, 'rb').read()
print('  gzip 主体一致:', body == expect)
print('  gzip 结束:', un.eof)
print('  尾部设备树一致:', un.unused_data == open(tree, 'rb').read())
PY
echo BOOTIMAGE_OK
