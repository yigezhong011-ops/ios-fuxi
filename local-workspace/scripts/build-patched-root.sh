#!/bin/bash
set -euo pipefail
RAW=/root/fuxi/root-patch.raw
M=/root/fuxi/mnt/patch
ART=/mnt/e/DSH-Fuxi/gles-stack
OUT=/mnt/e/DSH-Fuxi/gles-root2.simg

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

echo "=== 2) 替换 backboardd（加了一条 LC_LOAD_DYLIB）==="
BB="$M/usr/libexec/backboardd"
cp "$BB" /root/fuxi/backboardd.inimage
cp /root/fuxi/backboardd.patched "$BB"
chown 0:0 "$BB"
chmod 755 "$BB"
ls -l "$BB"
echo "=== 3) 校验镜像里的 backboardd 依赖 ==="
python3 - "$BB" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
magic, ct, cs, ft, ncmds, sizeofcmds, flags, _ = struct.unpack('<8I', d[:32])
off = 32
found = None
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', d, off)
    if cmd == 0xc:
        no = struct.unpack_from('<I', d, off + 8)[0]
        e = d.index(b'\0', off + no)
        name = d[off + no:e].decode()
        if 'redwood' in name:
            found = name
    off += size
print('ncmds=%d sizeofcmds=%d  bridge dep: %s' % (ncmds, sizeofcmds, found or 'MISSING'))
PY

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
        f.seek(1024 + 8)
        f.write(b'HFSJ')
        print('卷头 %r -> HFSJ' % cur)
    f.seek(1024 + 4)
    attr = struct.unpack('>I', f.read(4))[0]
    if not attr & 0x100:
        f.seek(1024 + 4)
        f.write(struct.pack('>I', attr | 0x100))
        print('置未挂载位')
PY
fsck.hfsplus -f -y "$RAW" 2>&1 | tail -2

echo "=== 5) 转回稀疏镜像 ==="
rm -f "$OUT"
img2simg "$RAW" "$OUT"
ls -lh "$OUT"
sha256sum "$OUT" | cut -c1-32
echo PATCH_ROOT_OK
