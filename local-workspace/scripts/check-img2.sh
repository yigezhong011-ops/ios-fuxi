#!/bin/bash
set -uo pipefail
IMG=/root/hackios/out/fuxi-boot.img
python3 - "$IMG" <<'PY'
import zlib, struct, sys, pathlib
d = pathlib.Path(sys.argv[1]).read_bytes()
i = d.find(b'\x1f\x8b\x08')
raw = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(d[i:])
print('decompressed:', len(raw))
j = raw.find(b'XNUP')
print('XNUP at:', hex(j) if j >= 0 else 'MISSING')
if j >= 0:
    size = struct.unpack_from('<I', raw, j + 4)[0]
    print('XNUP size:', size)
    p = j + 8
    end = j + 8 + size
    while p < end:
        name = raw[p:p+16].rstrip(b'\0').decode('ascii', 'replace')
        if not name:
            break
        n = struct.unpack_from('<I', raw, p + 16)[0]
        print(f'  entry {name!r}: {n} bytes')
        p += 24 + ((n + 15) // 16) * 16
# also show the first 32 bytes of the decompressed image (shim ARM64 header)
print('shim head:', raw[:32].hex())
print('shim magic@56:', raw[56:60])
PY
