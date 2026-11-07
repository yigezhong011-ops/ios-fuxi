#!/bin/bash
set -uo pipefail
L=$(find /mnt/e/DSH-Fuxi/ci/mesa-final -name 'libOSMesa.8.dylib' | head -1)
echo "文件: $L ($(stat -c%s "$L") B)"
python3 - "$L" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read(1 << 20)
n = struct.unpack('<I', d[16:20])[0]
off = 32
for _ in range(n):
    c, s = struct.unpack('<II', d[off:off + 8])
    if c == 0xd:  # LC_ID_DYLIB
        no = struct.unpack('<I', d[off + 8:off + 12])[0]
        e = d.index(b'\0', off + no)
        print('install name =', d[off + no:e].decode())
        break
    if s == 0:
        break
    off += s
PY
echo "=== 符号表行数 ==="
wc -l /mnt/e/DSH-Fuxi/ci/mesa-final/exported-gl.txt
