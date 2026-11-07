#!/bin/bash
# Read-only: SEC entry code in the running loader. FD base 0xA7100000 = file 0xc0.
python3 -I - <<'PY'
import struct, zlib
d = open('/mnt/e/DSH-Fuxi/t50-auto-hanghigh.img', 'rb').read()
k = struct.unpack_from('<I', d, 8)[0]
b = zlib.decompressobj(31).decompress(d[4096:4096 + k])
open('/tmp/ldr.bin', 'wb').write(b[:0x3000c0])
PY
dis() { aarch64-linux-gnu-objdump -D -b binary -m aarch64 --start-address=$1 --stop-address=$2 /tmp/ldr.bin | tail -n +8 | cut -c1-72; }
echo '--- ModuleEntry'; dis 0x790c0 0x79200
echo '--- ClearFrameBuffer and print'; dis 0x23c0 0x2438
echo '--- SecEntry assert'; dis 0x20f0 0x21c0
echo '--- SecMain tail of the entry path, 0x2200-0x2300'; dis 0x2200 0x2300
