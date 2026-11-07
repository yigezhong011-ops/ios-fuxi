#!/bin/bash
set -uo pipefail
python3 - /root/fuxi/backboardd.orig <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
magic, ct, cs, ft, ncmds, sizeofcmds, flags, _ = struct.unpack('<8I', d[:32])
print('ncmds=%d sizeofcmds=%d' % (ncmds, sizeofcmds))
off = 32
first_sect = None
text_off = None
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', d, off)
    if cmd == 0x19:  # LC_SEGMENT_64
        nsects = struct.unpack_from('<I', d, off + 64)[0]
        sect = off + 72
        for _ in range(nsects):
            sec_off = struct.unpack_from('<I', d, sect + 48)[0]  # 正确的偏移
            name = d[sect:sect + 16].split(b'\0')[0].decode()
            if sec_off and (first_sect is None or sec_off < first_sect):
                first_sect = sec_off
            if name == '__text' and sec_off:
                text_off = sec_off
            sect += 80
    off += size
end = 32 + sizeofcmds
print('加载命令结束: %#x' % end)
print('第一个 section 偏移: %#x' % (first_sect or 0))
print('__text 偏移: %#x' % (text_off or 0))
print('可用填充: %d 字节' % ((first_sect or 0) - end))
PY
