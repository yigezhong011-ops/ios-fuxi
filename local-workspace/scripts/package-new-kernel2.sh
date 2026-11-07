#!/bin/bash
# Build the payload by replacing files inside the expert payload volume (already a
# FAT32 image), then wrap it into a boot image with the same geometry.
set -euo pipefail
W=/root/fuxi/pkg
cd "$W"

cp /root/fuxi/expert-payload-vol.img "$W/payload-new.img"
for f in kernel.macho kernel.macho.adt kernel.macho.trustcache scratch-data.img; do
  mcopy -o -i "$W/payload-new.img" "$W/$f" "::/EFI/UniXNU/Payloads/$f"
  echo "  replaced $f"
done
mcopy -o -i "$W/payload-new.img" "$W/unixnu.toml" "::/EFI/UniXNU/unixnu.toml"
echo "payload 卷: $(stat -c%s "$W/payload-new.img") 字节"

echo "=== 从专家 boot.img 取固件主体与设备树 ==="
python3 - <<'PY'
import struct, zlib
from pathlib import Path
d = Path('/mnt/e/DSH-Fuxi/unixnu-expert-boot.img').read_bytes()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
Path('/root/fuxi/pkg/body.bin').write_bytes(body)
Path('/root/fuxi/pkg/tree.dtb').write_bytes(un.unused_data)
print('  主体 %d，设备树 %d' % (len(body), len(un.unused_data)))
PY

python3 - <<'PY'
import gzip, struct
from pathlib import Path
w = Path('/root/fuxi/pkg')
body = (w / 'body.bin').read_bytes()
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
payload = (w / 'payload-new.img').read_bytes()
assert len(payload) == total * 512, 'payload size %d != expected %d' % (len(payload), total * 512)
blob = gzip.compress(body[:fat] + payload, mtime=0) + (w / 'tree.dtb').read_bytes()
(w / 'Image.gz-dtb').write_bytes(blob)
print('  新 gzip 主体 %d 字节' % len(blob))
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-ourkernel.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-ourkernel.img
echo BOOTIMG_OK
