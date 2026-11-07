#!/bin/bash
# Repack the working image with the diagnostics overlay switched off so the
# compositor's own output reaches the panel.
set -euo pipefail
W=/root/fuxi/userboot
M=$W/mnt2
mkdir -p "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done

cp "$W/payload.img" "$W/payload-quiet.img"
mount -t vfat -o loop,rw "$W/payload-quiet.img" "$M"

python3 - "$M/EFI/UniXNU/unixnu.toml" <<'PY'
import re, sys
p = sys.argv[1]
t = open(p, encoding='utf-8').read()
m = re.search(r'args = "([^"]*)"', t)
args = m.group(1).split()

drop = {'-v', 'boot-progress=2', 'sheng-log=1', 'armcpu-diagnostics=1'}
kept = [a for a in args if a not in drop]
kept += ['boot-progress=0', 'sheng-log=0']
new = 'args = "' + ' '.join(kept) + '"'
t = t[:m.start()] + new + t[m.end():]
open(p, 'w', encoding='utf-8').write(t)
print('去掉:', sorted(drop))
print('新增: boot-progress=0 sheng-log=0')
print('保留的关键项:', [a for a in kept if 'gpu' in a or 'dpu' in a or 'vsync' in a or 'fb' in a])
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
payload = (w / 'payload-quiet.img').read_bytes()
assert len(payload) == total * 512
tree = (w / 'tree.dtb').read_bytes()
(w / 'Image.gz-dtb').write_bytes(gzip.compress(body[:fat] + payload, mtime=0) + tree)
print('gzip 主体 %d 字节' % (w / 'Image.gz-dtb').stat().st_size)
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-quiet.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-quiet.img
echo QUIET_OK
