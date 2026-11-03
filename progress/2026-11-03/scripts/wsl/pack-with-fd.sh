#!/bin/bash
# Wrap a payload volume with a freshly built firmware (BootShim + FD) instead of the
# userboot one, so the firmware can power the USB controller for the kernel console.
# Usage: pack-with-fd.sh <bootshim.bin> <fd.bin> <payload.img> <out-name>
set -euo pipefail
SHIM=$1
FD=$2
PAYLOAD=$3
OUT=$4
W=/root/fuxi/pkg-$OUT
rm -rf "$W"; mkdir -p "$W"

python3 - "$SHIM" "$FD" "$PAYLOAD" "$W" <<'PY'
import gzip, sys
from pathlib import Path
shim = Path(sys.argv[1])
fd = Path(sys.argv[2])
payload = Path(sys.argv[3])
outdir = Path(sys.argv[4])

shim_b = shim.read_bytes()
fd_b = fd.read_bytes()
FD_SIZE = 0x300000
if len(fd_b) < FD_SIZE:
    fd_b = fd_b + bytes(FD_SIZE - len(fd_b))
elif len(fd_b) > FD_SIZE:
    sys.exit('FD bigger than 0x300000: %d' % len(fd_b))
prefix = shim_b + fd_b
print('BootShim %d + FD %d = prefix %d bytes' % (len(shim_b), len(fd_b), len(prefix)))
tree = Path('/root/fuxi/userboot/tree.dtb').read_bytes()
body = gzip.compress(prefix + payload.read_bytes(), mtime=0) + tree
(outdir / 'Image.gz-dtb').write_bytes(body)
print('Image.gz-dtb %d bytes' % len(body))
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" -o "/mnt/e/DSH-Fuxi/$OUT.img" 2>&1 | tail -1
ls -lh "/mnt/e/DSH-Fuxi/$OUT.img"
echo "${OUT}_OK"
