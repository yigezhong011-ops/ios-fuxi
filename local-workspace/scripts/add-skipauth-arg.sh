#!/bin/bash
# The kernel builds without owner-root verification, so it needs the boot flag
# that skips the root authentication check.
set -euo pipefail
W=/root/fuxi/pkg2
M=$W/mnt
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mkdir -p "$M"

cp "$W/payload.img" "$W/payload-auth.img"
mount -t vfat -o loop,rw "$W/payload-auth.img" "$M"
python3 - "$M/EFI/UniXNU/unixnu.toml" <<'PY'
import re, sys
p = sys.argv[1]
t = open(p, encoding='utf-8').read()
if 'fuxi-owner-skip-root-auth=1' in t:
    print('已经有这个参数')
else:
    t = t.replace('args = "', 'args = "fuxi-owner-skip-root-auth=1 ', 1)
    open(p, 'w', encoding='utf-8').write(t)
    print('已加入 fuxi-owner-skip-root-auth=1')
m = re.search(r'args = "([^"]*)"', t)
print('前 12 个参数:', ' '.join(m.group(1).split()[:12]))
PY
sync
umount "$M"

python3 - <<'PY'
import gzip, struct, subprocess
from pathlib import Path
w = Path('/root/fuxi/pkg2')
body = (w / 'body.bin').read_bytes()
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
payload = (w / 'payload-auth.img').read_bytes()
assert len(payload) == total * 512, (len(payload), total * 512)
blob = gzip.compress(body[:fat] + payload, mtime=0) + (w / 'tree.dtb').read_bytes()
(w / 'Image.gz-dtb').write_bytes(blob)
print('新 gzip 主体 %d 字节' % len(blob))
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-skipauth.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-skipauth.img
echo BOOTIMG_OK
