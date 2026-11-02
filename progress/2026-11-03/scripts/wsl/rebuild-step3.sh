#!/bin/bash
# Rebuild the payload with the daily image's own kernel and arguments (buttons + DSI
# brightness) plus the wallpaper addon, so nothing that worked is lost.
set -uo pipefail
LOG=/root/rebuild-payload.log
exec >>"$LOG" 2>&1
echo "=== $(date) 第二次 payload 开始 ==="

W=/root/rebuild
DAILY=/mnt/e/DSH-Fuxi/t32-bl-daily.img

echo "--- 从日常版取内核与参数 ---"
python3 - "$DAILY" "$W" <<'PY'
import struct, sys, zlib
from pathlib import Path
img, w = Path(sys.argv[1]), Path(sys.argv[2])
d = img.read_bytes()
hs = struct.unpack_from('<I', d, 20)[0]
ks = struct.unpack_from('<I', d, 8)[0]
start = (hs + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ks])
fat = next(m for m in range(0, 8 << 20, 2)
           if len(body[m:m+512]) == 512 and body[m+0x52:m+0x5a].startswith(b'FAT32')
           and body[m+0x1fe:m+0x200] == b'\x55\xaa')
total = struct.unpack_from('<I', body, fat + 32)[0]
(w / 'daily-vol.img').write_bytes(body[fat:fat + total * 512])
print('  日常版卷 %d 字节' % (total * 512))
PY

mkdir -p "$W/dmnt"
mount -t vfat -o loop,ro "$W/daily-vol.img" "$W/dmnt"
cp "$W/dmnt/EFI/UniXNU/Payloads/kernel.macho" "$W/kernel-daily.macho"
grep -o 'args = "[^"]*"' "$W/dmnt/EFI/UniXNU/unixnu.toml" | sed 's/^args = "//; s/"$//' > "$W/args-daily.txt"
umount "$W/dmnt"
ls -l "$W/kernel-daily.macho"
echo "  参数 $(wc -w < "$W/args-daily.txt") 个"

echo "--- build payload ---"
TREE=/mnt/e/DSH-Fuxi/unixnu-build/unixnu
DEV=/mnt/e/DSH-Fuxi/unixnu-build/fuxi
cd "$TREE" || exit 1
./unixnu defconfig fuxi_full_defconfig -D "$DEV" 2>&1 | tail -1

set --
for a in $(cat "$W/args-daily.txt"); do set -- "$@" "--kernel-arg=$a"; done

./unixnu build payload -D "$DEV" \
  --kernel "$W/kernel-daily.macho" \
  --gpu-addon "$W/addon.ngpu" \
  --trust-cache "$W/trustcache" \
  --data-ramdisk "$W/data.img" \
  --unique-chip-id "${UNIXNU_UNIQUE_CHIP_ID:?set the device platform seed}" \
  "$@" 2>&1 | tail -12
echo "=== $(date) 结束 ==="
