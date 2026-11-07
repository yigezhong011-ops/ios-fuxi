#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/gles-stack/fuxi_gl_test
ls -l "$B"
python3 - "$B" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read(64)
m = struct.unpack('<I', d[:4])[0]
if m == 0xfeedfacf:
    ct, cs, ft = struct.unpack('<iiI', d[4:16])
    kinds = {2: 'executable', 6: 'dylib'}
    print('Mach-O 64: cputype=%d filetype=%d (%s)' % (ct, ft, kinds.get(ft, '?')))
else:
    print('not a Mach-O: %#x' % m)
PY
