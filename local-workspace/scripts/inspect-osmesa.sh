#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/ci/mesa-art
LIB=$(find "$D" -name 'libOSMesa.8.dylib' | head -1)
echo "文件: $LIB"
echo "大小: $(stat -c%s "$LIB") B"
echo "=== Mach-O 头部（cputype/subtype/filetype）==="
python3 - "$LIB" <<'PY'
import struct, sys
b = open(sys.argv[1], 'rb').read(64)
magic = struct.unpack('<I', b[:4])[0]
print('magic = 0x%08x (%s)' % (magic, 'Mach-O 64' if magic in (0xfeedfacf,) else '其它'))
if magic == 0xfeedfacf:
    cputype, cpusub, ftype, ncmds, sizeofcmds, flags = struct.unpack('<iiIIII', b[4:28])
    print('cputype = %d (16777228=arm64), cpusub = %d (2=v8)' % (cputype, cpusub))
    print('filetype = %d (6=dylib)' % ftype)
    print('ncmds = %d, flags = 0x%x' % (ncmds, flags))
PY
echo "=== LC_ID_DYLIB（install name）==="
python3 - "$LIB" <<'PY'
import struct, sys
data = open(sys.argv[1], 'rb').read(1 << 20)
ncmds = struct.unpack('<I', data[16:20])[0]
off = 32
for _ in range(ncmds):
    cmd, size = struct.unpack('<II', data[off:off+8])
    if cmd == 0xd:  # LC_ID_DYLIB
        name_off = struct.unpack('<I', data[off+8:off+12])[0]
        end = data.index(b'\0', off + name_off)
        print('id =', data[off+name_off:end].decode())
        break
    if size == 0:
        break
    off += size
PY
echo "=== 导出的 gl* 符号（前 10 个）==="
python3 - "$LIB" <<'PY'
import re, sys
data = open(sys.argv[1], 'rb').read()
syms = sorted(set(re.findall(rb'[_]?(gl[A-Z][A-Za-z0-9]{2,40})', data)))
print('粗数:', len(syms))
for s in syms[:10]:
    print(' ', s.decode())
PY
