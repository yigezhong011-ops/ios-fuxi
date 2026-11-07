#!/bin/bash
# Read-only: the running loader's stub and FD head, then the SEC strings with their code sites.
python3 -I - <<'PY'
import struct, zlib
d = open('/mnt/e/DSH-Fuxi/t50-auto-hanghigh.img', 'rb').read()
k = struct.unpack_from('<I', d, 8)[0]
b = zlib.decompressobj(31).decompress(d[4096:4096 + k])
open('/tmp/ldr.bin', 'wb').write(b[:0x3000c0])
PY
head -c 512 /tmp/ldr.bin > /tmp/h.bin
aarch64-linux-gnu-objdump -D -b binary -m aarch64 /tmp/h.bin | tail -n +8 | cut -c1-70 | head -50
echo ---strings
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/study-sec2.py > /tmp/ss2.py
python3 -I /tmp/ss2.py
