#!/usr/bin/env python3
"""Look up the touch symbols in the t50 kernel."""
import struct
import sys
from pathlib import Path

K = Path(sys.argv[1] if len(sys.argv) > 1 else '/root/fuxi/t50-shot/kernel.macho')
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

WANT = ('native_touch_seq', 'native_touch_count', 'native_touch_xs', 'native_touch_ys',
        'native_touch_ids', 'gTouchSink', 'gTouchSinkContext', 'native_touch_set_sink',
        'native_touch_strokes', 'native_touch_valid', 'native_touch_hid_reports')

found = {}
for i in range(nsyms):
    s = symoff + i * 16
    strx, ntype, nsect, ndesc, value = struct.unpack_from('<IBBHQ', data, s)
    end = strtab.find(b'\0', strx)
    name = strtab[strx:end].decode('utf-8', 'replace')
    for w in WANT:
        if w in name:
            found.setdefault(w, []).append((name, value))

for w in WANT:
    hits = found.get(w, [])
    if not hits:
        print('%-26s 未找到' % w)
        continue
    for name, value in hits[:3]:
        print('%-26s %s = 0x%x' % (w, name, value))
