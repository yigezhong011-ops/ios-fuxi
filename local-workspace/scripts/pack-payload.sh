#!/bin/bash
# Wrap a CI payload volume (out/<board>/.../payload/payload.img) into a fastboot boot image with the
# loader of user-boot.img (userboot/body.bin) and its appended DTB: the same container that boots our kernels.
# Usage: pack-payload.sh <payload.img> <out-name>   -> /mnt/e/DSH-Fuxi/<out-name>.img
set -euo pipefail
PAYLOAD=$1
OUT=$2
W=/root/fuxi/pkg-$OUT
rm -rf "$W"; mkdir -p "$W"
export MTOOLS_SKIP_CHECK=1
echo "=== payload ==="
mdir -i "$PAYLOAD" ::/EFI/UniXNU/Payloads | tail -8
mtype -i "$PAYLOAD" ::/EFI/UniXNU/unixnu.toml | grep -o 'fuxi-touch[^ "]*\|sheng-log[^ "]*\|sheng-data-persist[^ "]*' || true

python3 - "$PAYLOAD" "$W" <<'PY'
import gzip, sys
from pathlib import Path
payload, w = Path(sys.argv[1]).read_bytes(), Path(sys.argv[2])
body = Path('/root/fuxi/userboot/body.bin').read_bytes()
fat = next(m for m in range(0, 8 << 20, 2)
           if body[m + 0x52:m + 0x5a].startswith(b'FAT32') and body[m + 0x1fe:m + 0x200] == b'\x55\xaa')
tree = Path('/root/fuxi/userboot/tree.dtb').read_bytes()
(w / 'Image.gz-dtb').write_bytes(gzip.compress(body[:fat] + payload, mtime=0) + tree)
print('loader %d + payload %d bytes, gzip %d' % (fat, len(payload), (w / 'Image.gz-dtb').stat().st_size))
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" -o "/mnt/e/DSH-Fuxi/$OUT.img" 2>&1 | tail -1
ls -lh "/mnt/e/DSH-Fuxi/$OUT.img"
echo "${OUT}_OK"
