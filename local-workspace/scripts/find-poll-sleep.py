#!/usr/bin/env python3
# Read only: the blob calls through absolute addresses. Finds every movz/movk sequence that builds IOSleep's address, and each mov w0,#20.
import struct
K = '/root/fuxi/tap-t50-auto-g7cpu/kernel.macho'
T, SLEEP = 0xfffffff00c0902c0, 0xfffffff00bf0c2cc
k = open(K, 'rb').read()
at, segs = 32, []
for _ in range(struct.unpack_from('<I', k, 16)[0]):
    cmd, size = struct.unpack_from('<II', k, at)
    if cmd == 0x19:
        vm, _v, off, fs = struct.unpack_from('<QQQQ', k, at + 24)
        segs.append((vm, fs, off))
    at += size
def foff(va):
    for vm, fs, off in segs:
        if vm <= va < vm + fs:
            return off + va - vm
    raise SystemExit(hex(va))
n = 0x4000
w = struct.unpack_from('<%dI' % (n // 4), k, foff(T))
regs = {}
for i, x in enumerate(w):
    va = T + i * 4
    rd = x & 31
    if (x & 0xff800000) == 0xd2800000:      # movz x
        regs[rd] = (((x >> 5) & 0xffff) << (((x >> 21) & 3) * 16), va)
    elif (x & 0xff800000) == 0xf2800000 and rd in regs:      # movk x
        s = ((x >> 21) & 3) * 16
        regs[rd] = ((regs[rd][0] & ~(0xffff << s)) | (((x >> 5) & 0xffff) << s), regs[rd][1])
    elif (x & 0xff800000) == 0x92800000:      # movn x
        s = ((x >> 21) & 3) * 16
        regs[rd] = ((~(((x >> 5) & 0xffff) << s)) & (2 ** 64 - 1), va)
    if rd in regs and regs[rd][0] == SLEEP:
        print('sleep address in x%d complete at %s, started %s' % (rd, hex(va), hex(regs[rd][1])))
    if x == 0x52800280:
        print('mov w0,#20 at', hex(va), ' '.join('%08x' % y for y in w[max(0, i - 3):i + 8]))
