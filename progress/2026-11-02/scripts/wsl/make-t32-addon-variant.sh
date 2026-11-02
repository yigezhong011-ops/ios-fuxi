#!/bin/bash
# Build an image from the daily payload volume with ONLY the GPU addon replaced.
# Usage: make-t32-addon-variant.sh <out-name> <addon-file>
set -euo pipefail
OUT=$1
ADDON=$2
BASE_IMG=/mnt/e/DSH-Fuxi/t32-bl-daily.img
W=/root/fuxi/var-$OUT
rm -rf "$W"; mkdir -p "$W"

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
PY

tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
GPUADDON="$ADDON" bash /root/fuxi/make-arg-variant.sh "$W/vol.img" "$OUT" \
  | grep -E 'replaced|volume:|_OK'
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/bootimg-sizes.py "/mnt/e/DSH-Fuxi/$OUT.img" 2>/dev/null | tail -3
