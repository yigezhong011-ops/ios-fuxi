#!/bin/bash
set -uo pipefail
RAW=/root/fuxi/root-patch.raw
M=/root/fuxi/mnt/verify3
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,ro,force "$RAW" "$M"

echo "=== 库 ==="
ls -l "$M/redwood/lib/" 2>/dev/null
echo "=== 测试程序与 job ==="
ls -l "$M/usr/local/bin/fuxi_gl_test" 2>/dev/null
ls -l "$M/System/Library/LaunchDaemons/com.fuxi.gltest.plist" 2>/dev/null
echo "=== backboardd 依赖（这个镜像应为原版，无 redwood）==="
python3 - "$M/usr/libexec/backboardd" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
ncmds = struct.unpack('<I', d[16:20])[0]
off = 32
deps = []
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', d, off)
    if cmd == 0xc:
        no = struct.unpack_from('<I', d, off + 8)[0]
        e = d.index(b'\0', off + no)
        deps.append(d[off + no:e].decode())
    off += size
red = [x for x in deps if 'redwood' in x]
print('ncmds=%d, redwood 依赖: %s' % (ncmds, red or 'none (原版)'))
PY
echo "=== 卷头 ==="
xxd -l 16 -s 1024 "$RAW" | head -1
sync
umount "$M" 2>/dev/null || umount -l "$M" 2>/dev/null || true
