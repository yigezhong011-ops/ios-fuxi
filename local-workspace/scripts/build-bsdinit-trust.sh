#!/bin/bash
# Take the payload that reached bsd_init (ADT 13,544) untouched, add only the trust
# cache and the skip-auth flag, and repack.
set -euo pipefail
W=/root/fuxi/pkg6
rm -rf "$W"; mkdir -p "$W/mnt"
cd "$W"

cp /root/fuxi/pkg2/payload.img "$W/payload.img"     # ADT 13,544，能到 bsd_init
echo "=== 原始内容 ==="
mount -t vfat -o loop,ro "$W/payload.img" "$W/mnt"
find "$W/mnt" -type f -printf '  %-56p %10s B\n' | sort
umount "$W/mnt"

echo "=== 只加 trust cache + 参数 ==="
mount -t vfat -o loop,rw "$W/payload.img" "$W/mnt"
mcopy -o -i "$W/payload.img" /root/fuxi/pkg/kernel.macho.trustcache "::/EFI/UniXNU/Payloads/kernel.macho.trustcache"
python3 - "$W/mnt/EFI/UniXNU/unixnu.toml" <<'PY'
import sys
p = sys.argv[1]
t = open(p, encoding='utf-8').read()
if 'fuxi-owner-skip-root-auth=1' not in t:
    t = t.replace('args = "', 'args = "fuxi-owner-skip-root-auth=1 ', 1)
    open(p, 'w', encoding='utf-8').write(t)
    print('已加 skip-root-auth')
else:
    print('参数已在')
PY
sync
umount "$W/mnt"

echo "=== 校验 ==="
mount -t vfat -o loop,ro "$W/payload.img" "$W/mnt"
find "$W/mnt" -type f -printf '  %-56p %10s B\n' | sort
umount "$W/mnt"

echo "=== 打包 ==="
python3 - <<'PY'
import gzip, struct, zlib
from pathlib import Path
w = Path('/root/fuxi/pkg6')
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
print('  预期 %d 实际 %d' % (total * 512, len(payload)))
assert len(payload) == total * 512
(w / 'Image.gz-dtb').write_bytes(gzip.compress(body[:fat] + payload, mtime=0) + tree)
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-bsdinit-trust.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-bsdinit-trust.img
echo OK
