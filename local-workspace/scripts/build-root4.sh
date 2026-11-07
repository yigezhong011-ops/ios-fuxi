#!/bin/bash
set -euo pipefail
RAW=/root/fuxi/root-patch.raw
M=/root/fuxi/mnt/root4
OUT=/mnt/e/DSH-Fuxi/gles-root4.simg
ART=/mnt/e/DSH-Fuxi/gles-stack

mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$RAW" "$M"

echo "=== 1) 去掉上一轮加的 job 与测试程序 ==="
rm -f "$M/System/Library/LaunchDaemons/com.fuxi.gltest.plist"
rm -f "$M/usr/local/bin/fuxi_gl_test"

echo "=== 2) 只保留库 ==="
mkdir -p "$M/redwood/lib" "$M/usr/local/lib"
cp "$ART/libOSMesa.8.dylib" "$M/redwood/lib/libOSMesa.8.dylib"
cp "$ART/libredwood-gl.dylib" "$M/redwood/lib/libredwood-gl.dylib"
cp "$ART/libOSMesa.8.dylib" "$M/usr/local/lib/libOSMesa.8.dylib"
chown 0:0 "$M"/redwood/lib/*.dylib "$M"/usr/local/lib/libOSMesa.8.dylib
chmod 755 "$M"/redwood/lib/*.dylib "$M"/usr/local/lib/libOSMesa.8.dylib
ls -l "$M/redwood/lib/"
echo "=== 3) 确认 backboardd 是原版 ==="
python3 - "$M/usr/libexec/backboardd" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
ncmds = struct.unpack('<I', d[16:20])[0]
off = 32
red = []
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', d, off)
    if cmd == 0xc:
        no = struct.unpack_from('<I', d, off + 8)[0]
        e = d.index(b'\0', off + no)
        if 'redwood' in d[off+no:e].decode():
            red.append(d[off+no:e].decode())
    off += size
print('ncmds=%d, redwood 依赖: %s' % (ncmds, red or 'none (原版)'))
PY

echo "=== 4) 卸载 + 修卷头 + 打包 ==="
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
rm -f "$OUT"
img2simg "$RAW" "$OUT"
ls -lh "$OUT"
echo ROOT4_OK
