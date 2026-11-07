#!/bin/bash
# The ADT that reached bsd_init, with the owner-trust kernel dropped in.
set -euo pipefail
W=/root/fuxi/pkg8
rm -rf "$W"; mkdir -p "$W"
cd "$W"

python3 - <<'PY'
import zipfile
from pathlib import Path
with zipfile.ZipFile('/root/art-unixnu-fuxi-kernel-1.zip') as z:
    for name in z.namelist():
        if name.endswith('kernel.macho'):
            Path('/root/fuxi/pkg8/kernel.macho').write_bytes(z.read(name))
            print('新内核（owner-trust）就绪')
PY
ls -l kernel.macho
sha256sum kernel.macho | cut -c1-32

cp /root/fuxi/pkg2/payload.img payload.img
echo "=== 原 payload（ADT 13,544，能到 bsd_init）==="
mdir -i payload.img -/ ::/EFI/UniXNU/Payloads 2>/dev/null | tail -6

echo "=== 换内核 ==="
mcopy -o -i payload.img kernel.macho "::/EFI/UniXNU/Payloads/kernel.macho"

echo "=== 校验 ==="
mdir -i payload.img -/ ::/EFI/UniXNU/Payloads 2>/dev/null | tail -6
mtype -i payload.img ::/EFI/UniXNU/unixnu.toml | grep -o 'args = "[^"]*"' | cut -c1-130

echo "=== 打包 ==="
python3 - <<'PY'
import gzip, struct, zlib
from pathlib import Path
w = Path('/root/fuxi/pkg8')
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
payload = (w / 'payload.img').read_bytes()
print('  预期 %d 实际 %d' % (total * 512, len(payload)))
assert len(payload) == total * 512
(w / 'Image.gz-dtb').write_bytes(gzip.compress(body[:fat] + payload, mtime=0) + tree)
PY

printf '\0' > ramdisk1
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel Image.gz-dtb --ramdisk ramdisk1 \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-authtest.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-authtest.img
echo AUTHTEST_OK
