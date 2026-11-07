#!/bin/bash
set -euo pipefail
RAW=/root/fuxi/root6.raw
M=/root/fuxi/mnt/root6
OUT=/mnt/e/DSH-Fuxi/gles-root6-metal.simg

echo "=== 检查 staging 结果 ==="
ls -l "$M/usr/local/lib/" | head -5
ls -l "$M/System/Library/Extensions/FuxiMetal.bundle/" | head -6
cat "$M/usr/local/share/fuxi/metal-clients.conf"

echo "=== 卸载 + 修卷头 ==="
sync
umount "$M"
python3 - "$RAW" <<'PY'
import struct, sys
p = sys.argv[1]
with open(p, 'r+b') as f:
    f.seek(1024 + 8)
    cur = f.read(4)
    if cur != b'HFSJ':
        f.seek(1024 + 8); f.write(b'HFSJ'); print('卷头 %r -> HFSJ' % cur)
    f.seek(1024 + 4)
    attr = struct.unpack('>I', f.read(4))[0]
    if not attr & 0x100:
        f.seek(1024 + 4); f.write(struct.pack('>I', attr | 0x100))
PY
fsck.hfsplus -f -y "$RAW" 2>&1 | tail -2

echo "=== 打包 ==="
rm -f "$OUT"
img2simg "$RAW" "$OUT"
ls -lh "$OUT"
echo METAL_ROOT_OK
