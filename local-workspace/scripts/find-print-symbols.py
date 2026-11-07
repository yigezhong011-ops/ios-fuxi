#!/usr/bin/env python3
"""Look up the print function and the GPU counters in the t50 kernel."""
import struct
import sys
from pathlib import Path

K = Path(sys.argv[1] if len(sys.argv) > 1 else '/root/fuxi/t50-usbfast/kernel.macho')
data = K.read_bytes()
ncmds = struct.unpack_from('<I', data, 16)[0]
off = 32
symtab = None
for _ in range(ncmds):
    cmd, cmdsize = struct.unpack_from('<II', data, off)
    if cmd == 0x2:
        symtab = struct.unpack_from('<IIII', data, off + 8)
        break
    off += cmdsize
symoff, nsyms, stroff, strsize = symtab
strtab = data[stroff:stroff + strsize]

WANT = ('_kprintf', '_printf', 'native_adreno_fence_wait', 'native_adreno_submit_stats',
        'native_legacy_gop_virtual', 'native_legacy_gop_width', 'native_legacy_gop_height',
        'native_touch_hid_reports', 'native_touch_valid')

found = {}
for i in range(nsyms):
    s = symoff + i * 16
    strx, ntype, nsect, ndesc, value = struct.unpack_from('<IBBHQ', data, s)
    end = strtab.find(b'\0', strx)
    name = strtab[strx:end].decode('utf-8', 'replace')
    for w in WANT:
        if name == w or name.startswith(w + 'E') or name.startswith(w + 'C'):
            found.setdefault(w, []).append((name, value))

for w in WANT:
    hits = found.get(w, [])
    if not hits:
        print('%-32s 未找到' % w)
    for name, value in hits[:2]:
        print('%-32s %s = 0x%x' % (w, name, value))
