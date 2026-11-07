#!/bin/bash
set -uo pipefail
IMG=/root/hackios/out/fuxi-boot.img
python3 - "$IMG" <<'PY'
import zlib, struct, sys, pathlib
d = pathlib.Path(sys.argv[1]).read_bytes()
i = d.find(b'\x1f\x8b\x08')
raw = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(d[i:])
shim = raw[:240]
print('shim bytes:', len(shim))
# ARM64: movz x5, #imm16, lsl #16  -> 0xD2A00005 | imm16<<5
import re
code = shim[64:]           # skip the 64-byte header
words = struct.unpack('<%dI' % (len(code)//4), code[:len(code)//4*4])
print('shim instruction words:')
for w in words:
    # movz x5, #imm, lsl #16 : sf=1 opc=10 100101 hw=01 imm16 Rd
    if (w & 0xFFE0001F) == 0xD2A00005:
        imm = (w >> 5) & 0xFFFF
        print(f'  movz x5, #{imm:#x}, lsl #16  <-- PAYLOAD_BASE high half')
    if (w & 0xFFE0001F) == 0xD2A00003:
        imm = (w >> 5) & 0xFFFF
        print(f'  movz w3, #{imm:#x}, lsl #16')
PY
