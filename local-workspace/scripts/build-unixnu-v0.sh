#!/bin/bash
set -euo pipefail
cd /root/fuxi/unixnu
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py \
  --header_version 0 --pagesize 4096 \
  --kernel uefi.img \
  --ramdisk /mnt/e/DSH-Fuxi/unixnu-fuxi/fuxi/payload/payload.img \
  --os_version 16.0.0 --os_patch_level 2026-08 \
  -o /mnt/e/DSH-Fuxi/unixnu-fuxi-boot-v0.img 2>&1 | tail -3
ls -lh /mnt/e/DSH-Fuxi/unixnu-fuxi-boot-v0.img
python3 - /mnt/e/DSH-Fuxi/unixnu-fuxi-boot-v0.img <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read(64)
print('magic', d[:8])
ks, ka, rs, ra = struct.unpack_from('<4I', d, 8)
print('kernel_size=%d ramdisk_size=%d' % (ks, rs))
PY
