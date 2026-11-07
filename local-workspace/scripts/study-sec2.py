#!/usr/bin/env python3
# Read-only: list every SEC debug string with the code that loads it (adrp+add), by file offset, so bands can be hooked there. FD base 0xA7100000 = file 0xc0.
import re, struct, sys
l = open('/tmp/ldr.bin', 'rb').read()
BASE = 0xA7100000 - 0xc0
lim = 0x20000
strs = {}
for m in re.finditer(rb'[\x20-\x7e\n]{5,}\x00', l[:lim]):
    strs[m.start()] = m.group()[:-1]
for off in range(0xc0, lim - 8, 4):
    w = struct.unpack_from('<I', l, off)[0]
    if (w & 0x9F000000) == 0x90000000:   # adrp
        rd = w & 31
        imm = ((w >> 29) & 3) | (((w >> 5) & 0x7FFFF) << 2)
        if imm & (1 << 20): imm -= 1 << 21
        page = ((off + BASE) & ~0xFFF) + (imm << 12)
        for j in range(1, 6):
            w2 = struct.unpack_from('<I', l, off + 4 * j)[0]
            if (w2 & 0xFFC00000) == 0x91000000 and ((w2 >> 5) & 31) == rd:
                t = page + ((w2 >> 10) & 0xFFF) - BASE
                if t in strs:
                    print(hex(off), hex(off + 4 * j), repr(strs[t][:70]))
                break
    elif (w & 0x9F000000) == 0x10000000:  # adr
        imm = ((w >> 29) & 3) | (((w >> 5) & 0x7FFFF) << 2)
        if imm & (1 << 20): imm -= 1 << 21
        t = off + imm
        if t in strs:
            print(hex(off), 'adr', repr(strs[t][:70]))
