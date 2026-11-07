#!/bin/bash
# Read-only: the loader's entry stub, where the FD starts, and spare room.
L=/root/fuxi/loader.bin
xxd -l 0x100 $L | cut -c1-60
tail -c +1 $L | head -c 256 > /tmp/h.bin
llvm-objdump -D -b binary -m aarch64 /tmp/h.bin 2>/dev/null | tail -n +7 | cut -c1-70 | head -70 || true
python3 - <<'PY'
b = open('/root/fuxi/loader.bin', 'rb').read()
print('len', hex(len(b)))
i = 0xc0
print('at 0xc0', b[0xc0:0xd0].hex())
for m in (0x1000, 0x1100):
    print(hex(m), b[m:m+16].hex())
# zero or FF runs of at least 256 bytes in the first 64 KB and last 64 KB
def runs(lo, hi):
    j = lo
    while j < hi:
        if b[j] in (0, 0xff):
            k = j
            while k < hi and b[k] == b[j]: k += 1
            if k - j >= 256: print('run', hex(j), hex(k - j), hex(b[j]))
            j = k
        else: j += 1
runs(0, 0x10000); runs(len(b) - 0x20000, len(b))
PY
