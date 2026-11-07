#!/bin/bash
set -euo pipefail
RAW=/root/fuxi/root-patch.raw
M=/root/fuxi/mnt/patch
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$RAW" "$M"

BB="$M/usr/libexec/backboardd"
echo "=== backboardd ==="
ls -l "$BB"
cp "$BB" /root/fuxi/backboardd.orig
echo "=== 现有依赖（前 8 个）==="
python3 - /root/fuxi/backboardd.orig <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
magic, ct, cs, ft, ncmds, sizeofcmds, flags, _ = struct.unpack('<8I', d[:32])
print('magic=%#x cputype=%d filetype=%d ncmds=%d sizeofcmds=%d' % (magic, ct, ft, ncmds, sizeofcmds))
NAMES = {0xc: 'LOAD_DYLIB', 0xe: 'LOAD_DYLINKER', 0x80000022: 'DYLD_ENV', 0x1d: 'CODE_SIGNATURE', 0x19: 'SEGMENT'}
off = 32
shown = 0
first_sect = None
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', d, off)
    if cmd == 0xc and shown < 8:
        no = struct.unpack_from('<I', d, off + 8)[0]
        e = d.index(b'\0', off + no)
        print('  LOAD_DYLIB', d[off + no:e].decode())
        shown += 1
    if cmd == 0x19:
        nsects = struct.unpack_from('<I', d, off + 64)[0]
        so = off + 72
        for _ in range(nsects):
            o = struct.unpack_from('<I', d, so + 40)[0]
            if o and (first_sect is None or o < first_sect):
                first_sect = o
            so += 80
    off += size
print('第一个 section 的 file offset:', first_sect)
print('加载命令结束:', 32 + sizeofcmds)
print('可用填充:', (first_sect - (32 + sizeofcmds)) if first_sect else 'unknown')
PY
umount "$M" 2>/dev/null || umount -l "$M" 2>/dev/null || true
