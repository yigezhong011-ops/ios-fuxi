#!/bin/bash
set -euo pipefail
R=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/ios16-root-v11.raw
echo "=== 修改前 ==="
xxd -l 16 -s 1024 "$R"
# offset 0x408 (1024+8): lastMountedVersion -> HFSJ
printf 'HFSJ' | dd of="$R" bs=1 seek=1032 conv=notrunc status=none
# attributes at 0x404: set unmounted bit 0x100
python3 - "$R" <<'PY'
import struct, sys
p = sys.argv[1]
with open(p, 'r+b') as f:
    f.seek(1024 + 4)
    attr = struct.unpack('>I', f.read(4))[0]
    new = attr | 0x100
    f.seek(1024 + 4)
    f.write(struct.pack('>I', new))
    print('attributes %#x -> %#x' % (attr, new))
PY
echo "=== 修改后 ==="
xxd -l 16 -s 1024 "$R"
echo "=== fsck ==="
fsck.hfsplus -n "$R" 2>&1 | tail -3
