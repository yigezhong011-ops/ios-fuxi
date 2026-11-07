#!/bin/bash
# Package the CI payload (matching ADT + FTS touch kernel) into a boot image.
set -euo pipefail
W=/root/fuxi/pkg-ci
rm -rf "$W"; mkdir -p "$W/mnt"
cd "$W"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done

cp /root/fuxi/ci-payload.img "$W/payload.img"
echo "=== 内容 ==="
mount -t vfat -o loop,ro "$W/payload.img" "$W/mnt"
find "$W/mnt" -type f -printf '  %-58p %10s B\n' | sort
echo "=== 参数 ==="
grep -o 'args = "[^"]*"' "$W/mnt/EFI/UniXNU/unixnu.toml" | cut -c1-500
umount "$W/mnt"

python3 - <<'PY'
import gzip, struct
from pathlib import Path
w = Path('/root/fuxi/pkg-ci')
body = Path('/root/fuxi/userboot/body.bin').read_bytes()
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
payload = (w / 'payload.img').read_bytes()
tree = Path('/root/fuxi/userboot/tree.dtb').read_bytes()
print('原 payload 区起点 %d，新 payload %d 字节' % (fat, len(payload)))
(w / 'Image.gz-dtb').write_bytes(gzip.compress(body[:fat] + payload, mtime=0) + tree)
print('gzip 主体 %d 字节' % (w / 'Image.gz-dtb').stat().st_size)
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-fts3.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-fts3.img
echo FTS3_OK
