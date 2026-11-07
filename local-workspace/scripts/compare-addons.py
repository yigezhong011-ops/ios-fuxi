#!/usr/bin/env python3
"""Parse an NGPUADD2 container and list its files, so the old and the repacked
addons can be compared."""
import struct
import zlib
from pathlib import Path


def parse(path):
    d = Path(path).read_bytes()
    magic = d[:8]
    count, zero = struct.unpack_from('<II', d, 8)
    total = struct.unpack_from('<Q', d, 16)[0]
    print('%s: %s count=%d total=%d' % (Path(path).name, magic, count, total))
    off = 24
    files = []
    for _ in range(count):
        plen, mode, size, csize = struct.unpack_from('<IIQQ', d, off)
        off += 24
        name = d[off:off + plen].rstrip(b'\0').decode('utf-8', 'replace')
        off += (plen + 7) // 8 * 8
        blob = d[off:off + csize]
        off += (csize + 7) // 8 * 8
        try:
            data = zlib.decompress(blob)
            ok = len(data) == size
        except Exception:
            data, ok = b'', False
        files.append((name, mode, size, ok, data))
        print('  %-58s mode=%o size=%9d ok=%s' % (name, mode, size, ok))
    return files


old = parse('/root/fuxi/pkg5/root/EFI/UniXNU/Payloads/kernel.macho.gpuaddon')
print()
new = parse('/root/fuxi/addon-new/kernel.macho.gpuaddon')
print()
oldmap = {n: {k: v for k, v in zip(('mode', 'size', 'ok', 'data'), (m, s, ok, d))} for n, m, s, ok, d in old}
newmap = {n: {k: v for k, v in zip(('mode', 'size', 'ok', 'data'), (m, s, ok, d))} for n, m, s, ok, d in new}
print('=== 差异 ===')
for n in sorted(set(oldmap) | set(newmap)):
    if n not in oldmap:
        print('  只在新的:', n)
    elif n not in newmap:
        print('  只在旧的:', n)
    else:
        a, b = oldmap[n], newmap[n]
        same = a['data'] == b['data'] and a['mode'] == b['mode']
        print('  %-56s %s' % (n, '相同' if same else '不同(大小 %d vs %d)' % (a['size'], b['size'])))
