#!/bin/bash
# Read-only: unpack the loader's compressed FV (LZMA alone stream) and locate DarwinEnter.
python3 -I - <<'PY'
import lzma, struct, zlib
d = open('/mnt/e/DSH-Fuxi/t50-auto-hanghigh.img', 'rb').read()
k = struct.unpack_from('<I', d, 8)[0]
b = zlib.decompressobj(31).decompress(d[4096:4096 + k])[:0x3000c0]
pat = struct.pack('<I', 0xD50B7E24)
found = None
for i in range(0xc0, len(b) - 13):
    if b[i] != 0x5d or b[i + 1:i + 5] != b'\x00\x00\x00\x01' and b[i + 1:i + 5] != b'\x00\x00\x40\x00' and b[i + 1:i + 5] != b'\x00\x00\x00\x02' and b[i + 1:i + 5] != b'\x00\x00\x80\x00':
        continue
    size = struct.unpack_from('<Q', b, i + 5)[0]
    if not 0x10000 < size < 0x8000000:
        continue
    try:
        o = lzma.LZMADecompressor(format=lzma.FORMAT_ALONE).decompress(b[i:])
    except Exception as e:
        continue
    print('lzma at', hex(i), 'out', hex(len(o)))
    found = o
    break
open('/tmp/fv.bin', 'wb').write(found)
j = found.find(b'hand-off to the kernel')
print('string', hex(j))
i = 0
while True:
    i = found.find(pat, i)
    if i < 0: break
    ctx = struct.unpack_from('<4I', found, i - 8)
    if ctx[0] == 0xD5033F9F or True:
        print('dc civac x4 at', hex(i), 'page', hex(i & 0xfff), [hex(x) for x in ctx])
    if j > 0 and abs(i - j) < 0x100000:
        m = found.rfind(b'MZ', 0, i)
        print('  MZ', hex(m), 'offset', hex(i - m))
        open('/tmp/enter.bin', 'wb').write(found[i - 0x90:i + 0x60])
        print('  bytes before start', hex(i - 0x90 - m))
    i += 4
PY
aarch64-linux-gnu-objdump -D -b binary -m aarch64 /tmp/enter.bin 2>/dev/null | tail -n +8 | cut -c1-60
