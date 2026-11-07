#!/usr/bin/env python3
"""List the files of an NGPUADD2 GPU addon (layout in UniXNU scripts/make-gpu-addon.py); optional --extract DIR.
Usage: list-gpu-addon.py <addon> [--extract DIR]"""
import struct
import sys
import zlib
from pathlib import Path

data = Path(sys.argv[1]).read_bytes()
out = Path(sys.argv[sys.argv.index('--extract') + 1]) if '--extract' in sys.argv else None
if data[:8] != b'NGPUADD2':
    sys.exit('not an NGPUADD2 addon')
count, _, total = struct.unpack_from('<IIQ', data, 8)
off = 24
print(f'{count} files, total {total} bytes (file {len(data)})')
for _ in range(count):
    name_len, mode, size, csize = struct.unpack_from('<IIQQ', data, off)
    off += 24
    name = data[off:off + name_len - 1].decode()
    off += name_len + (-name_len % 8)
    packed = data[off:off + csize]
    off += csize + (-csize % 8)
    print(f'{mode:o} {size:>10} {csize:>9} {name}')
    if out:
        if '..' in name.split('/') or name.startswith('/'):
            sys.exit('bad path ' + name)
        dest = out / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(zlib.decompress(packed))
