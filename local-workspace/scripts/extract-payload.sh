#!/bin/bash
set -uo pipefail
IMG=/mnt/e/DSH-Fuxi/fuxi-diag.img
python3 - "$IMG" <<'PY'
import struct, sys, pathlib
d = pathlib.Path(sys.argv[1]).read_bytes()
i = d.find(b'SWEETXNU')
print('SWEETXNU at:', hex(i) if i >= 0 else 'NOT FOUND')
if i >= 0:
    virt, _, _, _, _, phys, size = struct.unpack_from('<7Q', d, i + 16)
    print(f'virt={virt:#x} phys={phys:#x} size={size:#x}')
    payload = d[i:i + 0x400 + size] if size else d[i:]
    out = pathlib.Path('/root/fuxi/payload-from-image.bin')
    out.write_bytes(payload)
    print('wrote', out, len(payload), 'bytes')
    print('cmdline:', d[i+72:i+72+120].split(b'\0')[0].decode('ascii', 'replace'))
PY
