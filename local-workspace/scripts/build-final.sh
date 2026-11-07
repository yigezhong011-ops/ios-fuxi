#!/bin/bash
# The CI payload already carries the matching ADT (with the TrustCache placeholder)
# and the trust cache; only the skip-auth argument is missing.
set -euo pipefail
W=/root/fuxi/pkg7
rm -rf "$W"; mkdir -p "$W"
cd "$W"

cp /root/fuxi/pkg3/payload.img "$W/payload.img"     # ADT 13,596 + trustcache（CI 生成）
echo "=== 原始内容 ==="
mdir -i "$W/payload.img" -/ ::/EFI/UniXNU/Payloads 2>/dev/null | tail -6

echo "=== 只改参数 ==="
mtype -i "$W/payload.img" ::/EFI/UniXNU/unixnu.toml > "$W/toml.orig"
python3 - "$W/toml.orig" "$W/toml.new" <<'PY'
import sys
src, dst = sys.argv[1], sys.argv[2]
t = open(src, encoding='utf-8', errors='replace').read()
if 'fuxi-owner-skip-root-auth=1' not in t:
    t = t.replace('args = "', 'args = "fuxi-owner-skip-root-auth=1 ', 1)
    print('已加 skip-root-auth')
else:
    print('已在')
open(dst, 'w', encoding='utf-8').write(t)
PY
mcopy -o -i "$W/payload.img" "$W/toml.new" "::/EFI/UniXNU/unixnu.toml"

echo "=== 校验 ==="
mdir -i "$W/payload.img" -/ ::/EFI/UniXNU/Payloads 2>/dev/null | tail -7
mtype -i "$W/payload.img" ::/EFI/UniXNU/unixnu.toml | grep -o 'args = "[^"]*"' | cut -c1-110

echo "=== 打包 ==="
python3 - <<'PY'
import gzip, struct, zlib
from pathlib import Path
w = Path('/root/fuxi/pkg7')
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

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-final.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-final.img
echo FINAL_OK
