#!/bin/bash
# Test whether the missing ADT property is what stops the boot: swap our payload's
# ADT for the one from the zip payload (which carries mix-n-match-prevention-status).
set -euo pipefail
W=/root/fuxi/adtcmp
SRC=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/payload/payload.img
IMG=/root/fuxi/unixnu/payload-theiradt.img
M=/root/fuxi/mnt/swap

cp -f "$SRC" "$IMG"
mkdir -p "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t vfat -o loop,rw "$IMG" "$M"

echo "=== 替换 ADT ==="
ls -l "$M/EFI/UniXNU/Payloads/kernel.macho.adt"
cp -f "$W/theirs.adt" "$M/EFI/UniXNU/Payloads/kernel.macho.adt"
sync
ls -l "$M/EFI/UniXNU/Payloads/kernel.macho.adt"
umount "$M"

echo "=== 重新打包启动镜像（payload 换成 theirs ADT）==="
OUT=/mnt/e/DSH-Fuxi/unixnu-fuxi-theiradt.img
python3 - "$IMG" "$OUT" <<'PY'
import gzip, struct, subprocess, sys, zlib
payload_path, out = sys.argv[1], sys.argv[2]
data = open('/root/fuxi/unixnu/uefi.img', 'rb').read()
d = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = d.decompress(data)
tree = d.unused_data
combined = body + open(payload_path, 'rb').read()
blob = gzip.compress(combined, mtime=0) + tree
open('/root/fuxi/unixnu/Image.gz-dtb-swap', 'wb').write(blob)
print('  combined %d -> %d 字节' % (len(combined), len(blob)))
PY
printf '\0' > /root/fuxi/unixnu/ramdisk1
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 4 --pagesize 4096 \
  --kernel /root/fuxi/unixnu/Image.gz-dtb-swap --ramdisk /root/fuxi/unixnu/ramdisk1 \
  --os_version 16.0.0 --os_patch_level 2026-08 -o "$OUT" 2>&1 | tail -2
ls -lh "$OUT"
echo SWAP_OK
