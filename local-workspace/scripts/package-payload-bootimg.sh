#!/bin/bash
# Package the CI-built payload (matching ADT) into a boot image.
set -euo pipefail
W=/root/fuxi/pkg2
rm -rf "$W"; mkdir -p "$W/mnt"
cd "$W"

python3 - <<'PY'
import zipfile
from pathlib import Path
with zipfile.ZipFile('/root/art-unixnu-fuxi-payload.zip') as z:
    for name in z.namelist():
        if name.endswith('payload.img'):
            data = z.read(name)
            out = Path('/root/fuxi/pkg2/payload.img')
            out.write_bytes(data)
            print('payload.img %d 字节' % len(data))
PY

echo "=== payload 里的文件 ==="
mount -t vfat -o loop,ro "$W/payload.img" "$W/mnt"
find "$W/mnt" -type f -printf '  %-56p %10s B\n' | sort
echo "--- unixnu.toml 的 args ---"
grep -o 'args = "[^"]*"' "$W/mnt/EFI/UniXNU/unixnu.toml" 2>/dev/null | head -1 | cut -c1-400
umount "$W/mnt"

echo "=== 用专家 boot.img 的固件主体 + 新 payload 组装 ==="
python3 - <<'PY'
import struct, zlib
from pathlib import Path
d = Path('/mnt/e/DSH-Fuxi/unixnu-expert-boot.img').read_bytes()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
Path('/root/fuxi/pkg2/body.bin').write_bytes(body)
Path('/root/fuxi/pkg2/tree.dtb').write_bytes(un.unused_data)
print('  主体 %d，设备树 %d' % (len(body), len(un.unused_data)))
PY

python3 - <<'PY'
import gzip, struct
from pathlib import Path
w = Path('/root/fuxi/pkg2')
body = (w / 'body.bin').read_bytes()
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
blob = gzip.compress(body[:fat] + payload, mtime=0) + (w / 'tree.dtb').read_bytes()
(w / 'Image.gz-dtb').write_bytes(blob)
print('  新 gzip 主体 %d 字节' % len(blob))
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-adtmatch.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-adtmatch.img
echo BOOTIMG_OK
