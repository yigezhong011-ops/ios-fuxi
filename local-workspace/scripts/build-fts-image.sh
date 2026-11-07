#!/bin/bash
# Put the FTS-touch kernel into the working payload (expert ADT, trust cache, addon,
# Data seed) and enable the fuxi touch probe.
set -euo pipefail
W=/root/fuxi/userboot
M=$W/mnt7
mkdir -p "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done

cp "$W/payload.img" "$W/payload-touch2.img"
mount -t vfat -o loop,rw "$W/payload-touch2.img" "$M"

echo "=== 替换内核 ==="
mcopy -o -i "$W/payload-touch2.img" /root/fuxi/touch-kernel.macho "::/EFI/UniXNU/Payloads/kernel.macho"
mdir -i "$W/payload-touch2.img" -/ ::/EFI/UniXNU/Payloads 2>/dev/null | tail -8

echo "=== 启动参数加 fuxi-touch ==="
python3 - "$M/EFI/UniXNU/unixnu.toml" <<'PY'
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
print('新增: fuxi-touch=4 fuxi-touch-panic=1')
print('触控参数:', [a for a in args if 'touch' in a])
PY
sync
umount "$M"

python3 - <<'PY'
import gzip, struct
from pathlib import Path
w = Path('/root/fuxi/userboot')
body = (w / 'body.bin').read_bytes()
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
payload = (w / 'payload-touch2.img').read_bytes()
assert len(payload) == total * 512, (len(payload), total * 512)
(w / 'Image.gz-dtb').write_bytes(gzip.compress(body[:fat] + payload, mtime=0) + (w / 'tree.dtb').read_bytes())
print('gzip %d' % (w / 'Image.gz-dtb').stat().st_size)
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-fts.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-fts.img
echo FTS_OK
