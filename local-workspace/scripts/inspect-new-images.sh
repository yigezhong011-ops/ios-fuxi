#!/bin/bash
set -uo pipefail
for IMG in /mnt/e/DSH-Fuxi/unixnu-quiet.img /mnt/e/DSH-Fuxi/unixnu-touch.img; do
  echo "================ $IMG ================"
  ls -l "$IMG"
  W=/root/insp-$(basename "$IMG" .img)
  rm -rf "$W"; mkdir -p "$W/mnt"
  python3 - "$IMG" "$W" <<'PY'
import gzip, struct, sys, zlib
from pathlib import Path
img, w = Path(sys.argv[1]), Path(sys.argv[2])
d = img.read_bytes()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
print('  头 %d，内核区 %d' % (hsize, ksize))
try:
    un = zlib.decompressobj(16 + zlib.MAX_WBITS)
    body = un.decompress(d[start:start + ksize])
    tree = un.unused_data
    print('  解压后主体 %d，设备树 %d' % (len(body), len(tree)))
    (w / 'body.bin').write_bytes(body)
    (w / 'tree.dtb').write_bytes(tree)
except Exception as e:
    print('  解压失败:', e)
    (w / 'body.bin').write_bytes(b'')
PY
  B="$W/body.bin"
  if [ -s "$B" ]; then
    OFF=$(python3 - "$B" <<'PY'
import struct, sys
body = open(sys.argv[1], 'rb').read()
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        print(m); break
else:
    print(-1)
PY
)
    echo "  payload 区起点: $OFF"
    if [ "$OFF" != "-1" ]; then
      dd if="$B" of="$W/payload.img" bs=512 skip=$((OFF / 512)) status=none
      mount -t vfat -o loop,ro "$W/payload.img" "$W/mnt" 2>/dev/null && {
        find "$W/mnt" -type f -printf '    %-52p %10s B\n' | sort
        echo "    --- 参数 ---"
        grep -o 'args = "[^"]*"' "$W/mnt/EFI/UniXNU/unixnu.toml" 2>/dev/null | head -1 | cut -c1-600
        umount "$W/mnt"
      }
    fi
  fi
done
