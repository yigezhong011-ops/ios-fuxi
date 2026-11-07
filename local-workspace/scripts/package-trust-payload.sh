#!/bin/bash
# Package the newest CI payload (with trust cache) into a boot image.
set -euo pipefail
W=/root/fuxi/pkg3
rm -rf "$W"; mkdir -p "$W/mnt"
cd "$W"

python3 - <<'PY'
import zipfile
from pathlib import Path
with zipfile.ZipFile('/root/art-unixnu-fuxi-payload.zip') as z:
    for name in z.namelist():
        if name.endswith('payload.img'):
            data = z.read(name)
            (Path('/root/fuxi/pkg3/payload.img')).write_bytes(data)
            print('payload.img %d 字节' % len(data))
PY

echo "=== payload 内容 ==="
mount -t vfat -o loop,ro "$W/payload.img" "$W/mnt"
find "$W/mnt" -type f -printf '  %-56p %10s B\n' | sort
umount "$W/mnt"

echo "=== 组装 boot.img ==="
python3 - <<'PY'
import gzip, struct, zlib
from pathlib import Path
w = Path('/root/fuxi/pkg3')
d = Path('/mnt/e/DSH-Fuxi/unixnu-expert-boot.img').read_bytes()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
tree = un.unused_data
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
payload = (w / 'payload.img').read_bytes()
print('  预期 payload %d，实际 %d' % (total * 512, len(payload)))
assert len(payload) == total * 512
blob = gzip.compress(body[:fat] + payload, mtime=0) + tree
(w / 'Image.gz-dtb').write_bytes(blob)
print('  gzip 主体 %d 字节' % len(blob))
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-trust.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-trust.img
echo BOOTIMG_OK
