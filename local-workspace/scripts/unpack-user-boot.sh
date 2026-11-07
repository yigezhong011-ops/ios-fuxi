#!/bin/bash
# Unpack the working boot image and read its payload configuration.
set -euo pipefail
W=/root/fuxi/userboot
rm -rf "$W"; mkdir -p "$W/mnt"
cd "$W"

python3 - <<'PY'
import gzip, struct, zlib
from pathlib import Path
src = Path('/mnt/e/DSH-Fuxi/user-boot.img')
d = src.read_bytes()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
Path('/root/fuxi/userboot/body.bin').write_bytes(body)
Path('/root/fuxi/userboot/tree.dtb').write_bytes(un.unused_data)
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
print('主体 %d，payload %d 字节，起点 %d，设备树 %d' % (len(body), total * 512, fat, len(un.unused_data)))
Path('/root/fuxi/userboot/payload.img').write_bytes(body[fat:fat + total * 512])
PY

echo "=== payload 内容 ==="
mount -t vfat -o loop,ro "$W/payload.img" "$W/mnt"
find "$W/mnt" -type f -printf '  %-58p %10s B\n' | sort
echo "=== 启动参数 ==="
grep -o 'args = "[^"]*"' "$W/mnt/EFI/UniXNU/unixnu.toml" | cut -c1-400
umount "$W/mnt"
