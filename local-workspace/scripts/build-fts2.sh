#!/bin/bash
# Rebuild the payload volume from scratch: replacing a 126 MB kernel with a 52 MB one
# corrupts the FAT bookkeeping when done in place.
set -euo pipefail
W=/root/fuxi/pkg-fts
rm -rf "$W"; mkdir -p "$W/root/EFI/UniXNU/Payloads"
cd "$W"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done

echo "=== 从原 working payload 取附件 ==="
mkdir -p "$W/mnt"
mount -t vfat -o loop,ro /root/fuxi/userboot/payload.img "$W/mnt"
cp "$W/mnt/EFI/UniXNU/Payloads/kernel.macho.adt"        "$W/root/EFI/UniXNU/Payloads/"
cp "$W/mnt/EFI/UniXNU/Payloads/kernel.macho.trustcache" "$W/root/EFI/UniXNU/Payloads/"
cp "$W/mnt/EFI/UniXNU/Payloads/kernel.macho.gpuaddon"   "$W/root/EFI/UniXNU/Payloads/"
cp "$W/mnt/EFI/UniXNU/Payloads/scratch-data.img"        "$W/root/EFI/UniXNU/Payloads/"
cp "$W/mnt/EFI/UniXNU/unixnu.toml"                      "$W/root/EFI/UniXNU/"
umount "$W/mnt"

echo "=== 放进新内核 ==="
cp /root/fuxi/touch-kernel.macho "$W/root/EFI/UniXNU/Payloads/kernel.macho"

echo "=== 改参数 ==="
python3 - "$W/root/EFI/UniXNU/unixnu.toml" <<'PY'
import re, sys
p = sys.argv[1]
t = open(p, encoding='utf-8').read()
m = re.search(r'args = "([^"]*)"', t)
args = m.group(1).split()
for a in ('fuxi-touch=4', 'fuxi-touch-panic=1'):
    key = a.split('=')[0]
    if not any(x.split('=')[0] == key for x in args):
        args.append(a)
t = t[:m.start()] + 'args = "' + ' '.join(args) + '"' + t[m.end():]
open(p, 'w', encoding='utf-8').write(t)
print('触控参数:', [a for a in args if 'touch' in a])
PY

echo "=== 新卷 ==="
IMG="$W/payload.img"
rm -f "$IMG"
truncate -s 184549376 "$IMG"
mformat -i "$IMG" -F -v FUXIESP ::
mcopy -i "$IMG" -s "$W/root/EFI" ::/
mdir -i "$IMG" -/ ::/EFI/UniXNU/Payloads 2>/dev/null | tail -8

python3 - <<'PY'
import gzip, struct
from pathlib import Path
w = Path('/root/fuxi/pkg-fts')
body = Path('/root/fuxi/userboot/body.bin').read_bytes()
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
payload = (w / 'payload.img').read_bytes()
tree = Path('/root/fuxi/userboot/tree.dtb').read_bytes()
(w / 'Image.gz-dtb').write_bytes(gzip.compress(body[:fat] + payload, mtime=0) + tree)
print('gzip 主体 %d 字节（原 payload 区 %d）' % ((w / 'Image.gz-dtb').stat().st_size, fat))
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-fts2.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-fts2.img
echo FTS2_OK
