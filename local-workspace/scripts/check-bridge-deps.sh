#!/bin/bash
set -uo pipefail
LIB=$(find /mnt/e/DSH-Fuxi/ci/bridge -name 'libredwood-gl.dylib' | head -1)
python3 - "$LIB" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read(1 << 20)
n = struct.unpack('<I', d[16:20])[0]
off = 32
NAMES = {0xc: 'LOAD_DYLIB', 0xd: 'ID_DYLIB', 0x8000001f: 'LOAD_UPWARD', 0x18f: 'LOAD_WEAK'}
for _ in range(n):
    c, s = struct.unpack('<II', d[off:off + 8])
    if c in NAMES:
        no = struct.unpack('<I', d[off + 8:off + 12])[0]
        e = d.index(b'\0', off + no)
        print('%-10s %s' % (NAMES[c], d[off + no:e].decode()))
    if s == 0:
        break
    off += s
PY
