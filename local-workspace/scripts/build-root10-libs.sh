#!/bin/bash
# Root with ONLY the GLES libraries (unmodified backboardd, no Metal plugin):
# the configuration that needs kern.exec_inject + the CS fix to work.
set -euo pipefail
PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
ART=/mnt/e/DSH-Fuxi/gles-stack
RAW=/root/fuxi/root10.raw
M=/root/fuxi/mnt/root10
OUT=/mnt/e/DSH-Fuxi/gles-root10-libs.simg

echo "=== 1) 转 raw ==="
[ -f "$RAW" ] || simg2img "$PKG/ios16-root-v11-fixed.simg" "$RAW"

echo "=== 2) 挂载 + 只装库 ==="
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$RAW" "$M"
mkdir -p "$M/redwood/lib" "$M/usr/local/lib"
cp "$ART/libOSMesa.8.dylib" "$M/redwood/lib/libOSMesa.8.dylib"
cp "$ART/libredwood-gl.dylib" "$M/redwood/lib/libredwood-gl.dylib"
cp "$ART/libOSMesa.8.dylib" "$M/usr/local/lib/libOSMesa.8.dylib"
chown 0:0 "$M"/redwood/lib/*.dylib "$M"/usr/local/lib/libOSMesa.8.dylib
chmod 755 "$M"/redwood/lib/*.dylib "$M"/usr/local/lib/libOSMesa.8.dylib
ls -l "$M/redwood/lib/"

echo "=== 3) 确认 backboardd 未改（应该没有 redwood 依赖）==="
python3 - "$M/usr/libexec/backboardd" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
n = struct.unpack('<I', d[16:20])[0]
off = 32; red = []
for _ in range(n):
    cmd, size = struct.unpack_from('<II', d, off)
    if cmd == 0xc:
        no = struct.unpack_from('<I', d, off + 8)[0]
        e = d.index(b'\0', off + no)
        name = d[off + no:e].decode()
        if 'redwood' in name:
            red.append(name)
    off += size
print('ncmds=%d  redwood 依赖: %s' % (n, red or 'none (未修改)'))
PY

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
echo ROOT10_OK
