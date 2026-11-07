#!/bin/bash
# Stage the Metal plugin so that backboardd (the window server) gets the device.
# This is the step we had never done: until now only the smoke binaries were clients.
set -euo pipefail

PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
ART=/mnt/e/DSH-Fuxi/ci/metal
ICD=/mnt/e/DSH-Fuxi/ci/mesa/libvulkan_freedreno.dylib
RAW=/root/fuxi/root6.raw
M=/root/fuxi/mnt/root6
SCRIPT=/mnt/e/DSH-Fuxi/dump/stage-fuxi-metal.py
OUT=/mnt/e/DSH-Fuxi/gles-root6-metal.simg

[ -f "$ICD" ] || { echo "missing ICD $ICD"; exit 1; }
[ -f "$ART/FuxiMetal.bundle/FuxiMetal" ] || { echo "missing bundle"; exit 1; }

echo "=== 1) 转 raw ==="
if [ ! -f "$RAW" ]; then
  simg2img "$PKG/ios16-root-v11-fixed.simg" "$RAW"
fi
ls -lh "$RAW"

echo "=== 2) 挂载 ==="
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$RAW" "$M"

echo "=== 3) staging（--enable-backboardd）==="
python3 "$SCRIPT" "$M" "$ICD" "$ART/FuxiMetal.bundle" "$ART/fuxi-metal-smoke" \
    --enable-backboardd 2>&1 | tail -20

echo "=== 4) 检查装了什么 ==="
ls -l "$M/usr/local/lib/" 2>/dev/null | head -6
ls -l "$M/System/Library/Extensions/FuxiMetal.bundle/" 2>/dev/null | head -5
ls -ld "$M/private/var/db/fuxi-metal"/* 2>/dev/null
echo "--- 客户端列表 ---"
cat "$M/usr/local/share/fuxi/metal-clients.conf" 2>/dev/null

echo "=== 5) 卸载 + 修卷头 ==="
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

echo "=== 6) 打包 ==="
rm -f "$OUT"
img2simg "$RAW" "$OUT"
ls -lh "$OUT"
echo METAL_ROOT_OK
