#!/bin/bash
set -uo pipefail
IMG=/root/hackios/out/fuxi-boot.img
echo "=== 镜像信息 ==="
ls -l "$IMG"
python3 - "$IMG" <<'PY'
import gzip, struct, sys, pathlib
d = pathlib.Path(sys.argv[1]).read_bytes()
print('magic:', d[:8])
# find the gzip stream
i = d.find(b'\x1f\x8b\x08')
print('gzip at:', hex(i) if i >= 0 else 'not found')
if i >= 0:
    raw = gzip.decompress(d[i:])
    print('decompressed:', len(raw))
    # shim is the first 240 bytes per the build log; payload magic should follow shim+FD
    j = raw.find(b'XNUP')
    print('XNUP at:', hex(j) if j >= 0 else 'MISSING')
    if j >= 0:
        size = struct.unpack_from('<I', raw, j + 4)[0]
        print('XNUP size:', size)
        # entry names
        p = j + 8
        while p < j + 8 + size:
            name = raw[p:p+16].rstrip(b'\0').decode('ascii', 'replace')
            if not name:
                break
            n = struct.unpack_from('<I', raw, p + 16)[0]
            print(f'  entry {name!r} {n} bytes')
            p += 24 + ((n + 15) // 16) * 16
PY
