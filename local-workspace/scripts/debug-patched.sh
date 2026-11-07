#!/bin/bash
set -uo pipefail
python3 - <<'PY'
import struct
d = open('/root/fuxi/backboardd.patched', 'rb').read()
magic, ct, cs, ft, ncmds, sizeofcmds, flags, _ = struct.unpack('<8I', d[:32])
print('ncmds=%d sizeofcmds=%d' % (ncmds, sizeofcmds))
off = 32
last = []
for i in range(ncmds):
    cmd, size = struct.unpack_from('<II', d, off)
    last.append((i, hex(cmd), size, hex(off)))
    if i >= ncmds - 3:
        print('cmd[%d] = %s size=%d at %s' % (i, hex(cmd), size, hex(off)))
        if cmd == 0xc:
            no = struct.unpack_from('<I', d, off + 8)[0]
            e = d.index(b'\0', off + no)
            print('   -> ', d[off + no:e].decode())
    off += size
print('总结束 offset = %#x (应为 %#x)' % (off, 32 + sizeofcmds))
# 看看 0x1e68 附近有什么
print('0x1e60..0x1e80:', d[0x1e60:0x1e80].hex())
PY
