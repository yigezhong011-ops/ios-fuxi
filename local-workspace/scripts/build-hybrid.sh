#!/bin/bash
# Best known combination: our kernel with the expert payload's ADT (which reaches
# bsd_init), plus the trust cache and the skip-auth flag.
set -euo pipefail
W=/root/fuxi/pkg4
rm -rf "$W"; mkdir -p "$W/mnt"
cd "$W"

cp /mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/payload/payload.img "$W/base.img" 2>/dev/null || \
  cp /root/fuxi/expert-payload-vol.img "$W/base.img"

# our kernel
python3 - <<'PY'
import zipfile
from pathlib import Path
with zipfile.ZipFile('/root/art-unixnu-fuxi-kernel-1.zip') as z:
    for name in z.namelist():
        if name.endswith('kernel.macho'):
            (Path('/root/fuxi/pkg4/kernel.macho')).write_bytes(z.read(name))
            print('kernel.macho 就绪')
PY
cp /root/fuxi/pkg/kernel.macho.adt         "$W/kernel.macho.adt"           2>/dev/null || true
cp /root/fuxi/pkg/kernel.macho.trustcache  "$W/kernel.macho.trustcache"  2>/dev/null || true
cp /root/fuxi/pkg/scratch-data.img         "$W/scratch-data.img"         2>/dev/null || true
ls -l "$W" | head -8

for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
cp "$W/base.img" "$W/payload-hybrid.img"
mount -t vfat -o loop,rw "$W/payload-hybrid.img" "$W/mnt"
echo "=== 原始 payload 内容 ==="
find "$W/mnt" -type f -printf '  %-56p %10s B\n' | sort

mcopy -o -i "$W/payload-hybrid.img" "$W/kernel.macho" "::/EFI/UniXNU/Payloads/kernel.macho"
[ -f "$W/kernel.macho.adt" ] && mcopy -o -i "$W/payload-hybrid.img" "$W/kernel.macho.adt" "::/EFI/UniXNU/Payloads/kernel.macho.adt"
[ -f "$W/kernel.macho.trustcache" ] && mcopy -o -i "$W/payload-hybrid.img" "$W/kernel.macho.trustcache" "::/EFI/UniXNU/Payloads/kernel.macho.trustcache"
[ -f "$W/scratch-data.img" ] && mcopy -o -i "$W/payload-hybrid.img" "$W/scratch-data.img" "::/EFI/UniXNU/Payloads/scratch-data.img"

python3 - "$W/mnt/EFI/UniXNU/unixnu.toml" <<'PY'
import re, sys
p = sys.argv[1]
t = open(p, encoding='utf-8').read()
if 'fuxi-owner-skip-root-auth=1' not in t:
    t = t.replace('args = "', 'args = "fuxi-owner-skip-root-auth=1 ', 1)
    open(p, 'w', encoding='utf-8').write(t)
    print('已加 skip-root-auth 参数')
else:
    print('参数已在')
PY
sync
umount "$W/mnt"

python3 - <<'PY'
import gzip, struct, zlib
from pathlib import Path
w = Path('/root/fuxi/pkg4')
d = Path('/mnt/e/DSH-Fuxi/unixnu-expert-boot.img').read_bytes()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
tree = un.unused_data
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
payload = (w / 'payload-hybrid.img').read_bytes()
print('  预期 %d，实际 %d' % (total * 512, len(payload)))
assert len(payload) == total * 512
(w / 'Image.gz-dtb').write_bytes(gzip.compress(body[:fat] + payload, mtime=0) + tree)
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-hybrid.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-hybrid.img
echo HYBRID_OK
