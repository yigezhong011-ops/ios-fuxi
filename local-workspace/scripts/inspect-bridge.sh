#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/ci/bridge
LIB=$(find "$D" -name 'libredwood-gl.dylib' | head -1)
echo "=== libredwood-gl.dylib ==="
echo "大小: $(stat -c%s "$LIB") B"
python3 - "$LIB" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read(1 << 20)
magic = struct.unpack('<I', d[:4])[0]
ct, cs, ft = struct.unpack('<iiI', d[4:16])
print('magic=0x%08x cputype=%d filetype=%d' % (magic, ct, ft))
n = struct.unpack('<I', d[16:20])[0]
off = 32
ids = []
for _ in range(n):
    c, s = struct.unpack('<II', d[off:off + 8])
    if c == 0xd:
        no = struct.unpack('<I', d[off + 8:off + 12])[0]
        e = d.index(b'\0', off + no)
        ids.append(d[off + no:e].decode())
    if s == 0:
        break
    off += s
print('install name =', ids[0] if ids else '(none)')
PY
echo
echo "=== 依赖（应指向 /redwood/lib/libOSMesa.8.dylib）==="
python3 - "$LIB" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read(1 << 20)
n = struct.unpack('<I', d[16:20])[0]
off = 32
for _ in range(n):
    c, s = struct.unpack('<II', d[off:off + 8])
    if c in (0xd, 0x8000001f):  # LC_ID_DYLIB / LC_LOAD_DYLIB
        no = struct.unpack('<I', d[off + 8:off + 12])[0]
        e = d.index(b'\0', off + no)
        kind = 'ID ' if c == 0xd else 'NEED'
        print(kind, d[off + no:e].decode())
    if s == 0:
        break
    off += s
PY
echo
echo "=== eagl_gen.h：生成的槽位函数数 ==="
grep -c '^static ' /mnt/e/DSH-Fuxi/ci/bridge/eagl_gen.h || true
head -6 /mnt/e/DSH-Fuxi/ci/bridge/eagl_gen.h
