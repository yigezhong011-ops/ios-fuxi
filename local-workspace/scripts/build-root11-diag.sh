#!/bin/bash
# Root for GLES diagnostics: libraries + backboardd's own output on /dev/console,
# so the bridge's "redwood-gl:" / "gl:" lines reach the screen.
set -euo pipefail
PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
ART=/mnt/e/DSH-Fuxi/gles-stack
RAW=/root/fuxi/root11.raw
M=/root/fuxi/mnt/root11
OUT=/mnt/e/DSH-Fuxi/gles-root11-diag.simg
PLIST=System/Library/LaunchDaemons/com.apple.backboardd.plist

echo "=== 1) 转 raw ==="
[ -f "$RAW" ] || simg2img "$PKG/ios16-root-v11-fixed.simg" "$RAW"

echo "=== 2) 挂载 ==="
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$RAW" "$M"

echo "=== 3) 装库 + 重定向 backboardd 输出 ==="
mkdir -p "$M/redwood/lib" "$M/usr/local/lib"
cp "$ART/libOSMesa.8.dylib" "$M/redwood/lib/libOSMesa.8.dylib"
cp "$ART/libredwood-gl.dylib" "$M/redwood/lib/libredwood-gl.dylib"
cp "$ART/libOSMesa.8.dylib" "$M/usr/local/lib/libOSMesa.8.dylib"
chown 0:0 "$M"/redwood/lib/*.dylib "$M"/usr/local/lib/libOSMesa.8.dylib
chmod 755 "$M"/redwood/lib/*.dylib "$M"/usr/local/lib/libOSMesa.8.dylib

python3 - "$M/$PLIST" <<'PY'
import plistlib, sys
p = sys.argv[1]
d = plistlib.load(open(p, 'rb'))
d['StandardOutPath'] = '/dev/console'
d['StandardErrorPath'] = '/dev/console'
plistlib.dump(d, open(p, 'wb'))
print('backboardd 的 stdout/stderr -> /dev/console')
PY
chown 0:0 "$M/$PLIST"; chmod 644 "$M/$PLIST"

echo "=== 4) 卸载 + 卷头 + 打包 ==="
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
fsck.hfsplus -f -y "$RAW" 2>&1 | tail -1
rm -f "$OUT"
img2simg "$RAW" "$OUT"
ls -lh "$OUT"
rm -f "$RAW"
echo ROOT11_OK
