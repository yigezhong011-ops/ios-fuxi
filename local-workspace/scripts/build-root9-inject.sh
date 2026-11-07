#!/bin/bash
# GLES route on our own kernel: libraries + a backboardd carrying an LC_LOAD_DYLIB
# for the EAGL bridge. The earlier panic ("unexpected exec of non-platform binary")
# happened on the author's closed-source kernel; ours has never been tested.
set -euo pipefail
RAW=/root/fuxi/root8.raw
M=/root/fuxi/mnt/root9
OUT=/mnt/e/DSH-Fuxi/gles-root9-inject.simg
ART=/mnt/e/DSH-Fuxi/gles-stack
TOOL=/mnt/e/DSH-Fuxi/dump/wsl/insert-dylib.py

mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$RAW" "$M"

echo "=== 1) 装库 ==="
mkdir -p "$M/redwood/lib" "$M/usr/local/lib"
cp "$ART/libOSMesa.8.dylib" "$M/redwood/lib/libOSMesa.8.dylib"
cp "$ART/libredwood-gl.dylib" "$M/redwood/lib/libredwood-gl.dylib"
cp "$ART/libOSMesa.8.dylib" "$M/usr/local/lib/libOSMesa.8.dylib"
chown 0:0 "$M"/redwood/lib/*.dylib "$M"/usr/local/lib/libOSMesa.8.dylib
chmod 755 "$M"/redwood/lib/*.dylib "$M"/usr/local/lib/libOSMesa.8.dylib

echo "=== 2) 给 backboardd 加 LC_LOAD_DYLIB ==="
BB="$M/usr/libexec/backboardd"
cp "$BB" /root/fuxi/backboardd.orig9
python3 "$TOOL" /root/fuxi/backboardd.orig9 /redwood/lib/libredwood-gl.dylib --out /root/fuxi/backboardd.patched9
cp /root/fuxi/backboardd.patched9 "$BB"
chown 0:0 "$BB"; chmod 755 "$BB"
ls -l "$BB"

echo "=== 3) 校验 ==="
python3 - "$BB" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
ncmds = struct.unpack('<I', d[16:20])[0]
off = 32; found = None
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', d, off)
    if cmd == 0xc:
        no = struct.unpack_from('<I', d, off + 8)[0]
        e = d.index(b'\0', off + no)
        name = d[off + no:e].decode()
        if 'redwood' in name:
            found = name
    off += size
print('ncmds=%d  bridge 依赖: %s' % (ncmds, found or 'MISSING'))
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
echo ROOT9_OK
