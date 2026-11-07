#!/bin/bash
# Same Metal root as root6, plus two launchd keys that send backboardd's own
# output to /dev/console -- which on this kernel is the framebuffer console.

set -euo pipefail
PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
ART=/mnt/e/DSH-Fuxi/ci/metal
ICD=/mnt/e/DSH-Fuxi/ci/mesa/libvulkan_freedreno.dylib
RAW=/root/fuxi/root7.raw
M=/root/fuxi/mnt/root7
SCRIPT=/mnt/e/DSH-Fuxi/dump/stage-fuxi-metal.py
OUT=/mnt/e/DSH-Fuxi/gles-root7-console.simg
PLIST=System/Library/LaunchDaemons/com.apple.backboardd.plist

[ -f "$ICD" ] || { echo "missing ICD"; exit 1; }
[ -f "$ART/FuxiMetal.bundle/FuxiMetal" ] || { echo "missing bundle"; exit 1; }

echo "=== 1) 转 raw ==="
[ -f "$RAW" ] || simg2img "$PKG/ios16-root-v11-fixed.simg" "$RAW"

echo "=== 2) 挂载 + staging ==="
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$RAW" "$M"
python3 "$SCRIPT" "$M" "$ICD" "$ART/FuxiMetal.bundle" "$ART/fuxi-metal-smoke" \
    --conf "$ART/metal-smoke.conf" --clients "$ART/metal-clients.conf" \
    --ca-conf "$ART/ca-smoke.conf" --enable-backboardd 2>&1 | tail -3

echo "=== 3) backboardd 的输出改到 /dev/console ==="
python3 - "$M/$PLIST" <<'PY'
import plistlib, sys
p = sys.argv[1]
d = plistlib.load(open(p, 'rb'))
print('原有键:', sorted(d.keys()))
d['StandardOutPath'] = '/dev/console'
d['StandardErrorPath'] = '/dev/console'
plistlib.dump(d, open(p, 'wb'))
print('已写入 StandardOutPath/StandardErrorPath = /dev/console')
PY
chown 0:0 "$M/$PLIST"; chmod 644 "$M/$PLIST"

echo "=== 4) 卸载 + 修卷头 ==="
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
    a = struct.unpack('>I', f.read(4))[0]
    if not a & 0x100:
        f.seek(1024 + 4); f.write(struct.pack('>I', a | 0x100))
PY
fsck.hfsplus -f -y "$RAW" 2>&1 | tail -2

echo "=== 5) 打包 ==="
rm -f "$OUT"
img2simg "$RAW" "$OUT"
ls -lh "$OUT"
rm -f "$RAW"
echo ROOT7_OK
