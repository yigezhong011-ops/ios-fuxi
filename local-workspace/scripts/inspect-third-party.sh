#!/bin/bash
# Inspect a third-party UniXNU boot image: payload files, boot arguments, and whether its kernel / loader / ADT
# match ones we already have (user-boot.img). Read-only.
# Usage: inspect-third-party.sh <boot.img> <work-dir>
set -euo pipefail
IMG=$1
W=$2
mkdir -p "$W"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/extract-boot-adt.py "$IMG" "$W/p"
python3 -I - "$IMG" "$W" <<'PY'
import struct, sys, zlib, hashlib
from pathlib import Path
img, w = sys.argv[1], Path(sys.argv[2])
data = open(img, 'rb').read()
ks = struct.unpack_from('<I', data, 8)[0]
body = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(data[4096:4096 + ks])
fat = next(m for m in range(0, 8 << 20, 2) if body[m + 0x52:m + 0x5a].startswith(b'FAT32') and body[m + 0x1fe:m + 0x200] == b'\x55\xaa')
(w / 'vol.img').write_bytes(body[fat:])
ub = Path('/root/fuxi/userboot/body.bin').read_bytes()
print('loader identical to user-boot.img:', body[:fat] == ub[:fat])
PY
export MTOOLS_SKIP_CHECK=1
echo "== payload files"; mdir -i "$W/vol.img" ::/EFI/UniXNU/Payloads | grep -v '^$'
for f in kernel.macho kernel.macho.gpuaddon kernel.macho.trustcache; do
  mcopy -o -i "$W/vol.img" ::/EFI/UniXNU/Payloads/$f "$W/$f" 2>/dev/null && sha256sum "$W/$f" | cut -c1-16 | sed "s/^/  $f /" || true
done
echo "== user-boot.img for comparison"
mkdir -p /root/fuxi/_m; mount -o loop,ro /root/fuxi/userboot/payload.img /root/fuxi/_m
for f in kernel.macho kernel.macho.gpuaddon kernel.macho.trustcache; do sha256sum /root/fuxi/_m/EFI/UniXNU/Payloads/$f | cut -c1-16 | sed "s/^/  $f /"; done
umount /root/fuxi/_m
echo "== kernel"
grep -a -o -m1 'Darwin Kernel Version [^)]*' "$W/kernel.macho" | head -1
echo "  FTS strings: $(grep -a -c 'FTS' "$W/kernel.macho" || true)  fuxi-touch args: $(grep -a -o 'fuxi-touch[a-z-]*' "$W/kernel.macho" | sort -u | tr '\n' ' ')"
echo "  Novatek: $(grep -a -c NvtTouchCore "$W/kernel.macho" || true)"
echo "== boot args (diff against user-boot.img)"
grep args "$W/p.toml" | tr ' ' '\n' | sed 's/^args = "//;s/"$//' | sort > "$W/args.txt"
mcopy -o -i /root/fuxi/userboot/payload.img ::/EFI/UniXNU/unixnu.toml "$W/ub.toml"
grep args "$W/ub.toml" | tr ' ' '\n' | sed 's/^args = "//;s/"$//' | sort > "$W/ub-args.txt"
diff "$W/ub-args.txt" "$W/args.txt" || true
echo "== storage-writing args present:"; grep -E 'sheng-log|sheng-data-persist' "$W/args.txt" || echo "  none"
