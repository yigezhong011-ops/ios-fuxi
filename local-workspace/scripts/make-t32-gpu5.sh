#!/bin/bash
# t32-gpu5: the daily image's own payload volume with ONLY the GPU addon's client list
# changed (mediaserverd -> Preferences). No argument edits, no kernel replacement, no
# removed addon entries and no filler: the addon is byte-for-byte the same length.
set -euo pipefail

BASE_IMG=/mnt/e/DSH-Fuxi/t32-bl-daily.img
W=/root/fuxi/gpu5
rm -rf "$W"; mkdir -p "$W"

echo "=== 从日常版镜像取出载荷卷 ==="
python3 - "$BASE_IMG" "$W/vol.img" <<'PY'
import struct, sys, zlib
from pathlib import Path
img, out = Path(sys.argv[1]), Path(sys.argv[2])
d = img.read_bytes()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
out.write_bytes(body[fat:fat + total * 512])
print('  卷 %d 字节，payload 起点 %d' % (total * 512, fat))
PY

echo "=== 只替换 addon（参数不变、内核不变）==="
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
GPUADDON=/root/fuxi/t32/addon-gpu5 \
bash /root/fuxi/make-arg-variant.sh "$W/vol.img" t32-gpu5 \
  | grep -E 'replaced|volume:|_OK|args:'
