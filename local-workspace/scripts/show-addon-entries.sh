#!/bin/bash
# Verify the fitted addon: size and entry list (works around PowerShell quoting).
set -uo pipefail
A=${1:-/root/fuxi/gpu-new-t50-mine/addon-fitted.bin}
python3 - "$A" <<'PY'
import struct, sys
p = sys.argv[1]
d = open(p, 'rb').read()
cnt = struct.unpack_from('<I', d, 8)[0]
off = 24
print('文件 %s' % p)
print('总长 %d 字节，%d 个条目' % (len(d), cnt))
for _ in range(cnt):
    nl, md, sz, cs = struct.unpack_from('<IIQQ', d, off)
    off += 24
    nm = d[off:off + nl - 1].decode()
    off += nl + (-nl % 8)
    print('  %-46s 解压 %9d 压缩 %9d' % (nm, sz, cs))
    off += cs + (-cs % 8)
PY
