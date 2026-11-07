#!/bin/bash
# Callers of native_hid_input_allocate (buttons + touch device, +0xe3 = 0) and native_hid_touch_allocate (touch-only, +0xe3 = 1),
# and the boot arguments parsed just before each call.
K=/root/fuxi/t32/kernel.macho
python3 - "$K" <<'PY'
import bisect, re, struct, subprocess, sys
k = open(sys.argv[1], 'rb').read()
ncmds = struct.unpack_from('<I', k, 16)[0]; segs = []; off = 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, off)
    if cmd == 0x19:
        name = k[off + 8:off + 24].split(b'\0')[0].decode()
        vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<4Q', k, off + 24); segs.append((name, vmaddr, fileoff, filesize))
    off += size
nm = subprocess.run(['llvm-nm', '--defined-only', sys.argv[1]], capture_output=True, text=True).stdout
syms = {}
for l in nm.splitlines():
    p = l.split()
    if len(p) == 3: syms.setdefault(p[2], int(p[0], 16))
addrs = sorted((v, n) for n, v in syms.items()); keys = [a for a, _ in addrs]
def owner(va): return addrs[bisect.bisect_right(keys, va) - 1]
targets = {syms['_native_hid_input_allocate']: 'native_hid_input_allocate', syms['_native_hid_touch_allocate']: 'native_hid_touch_allocate'}
for name, vmaddr, fileoff, filesize in segs:
    if name != '__TEXT_EXEC': continue
    code = k[fileoff:fileoff + filesize]
    for i in range(0, len(code), 4):
        w = struct.unpack_from('<I', code, i)[0]
        if w >> 26 not in (0b100101, 0b000101): continue
        d = w & 0x3ffffff; d -= (1 << 26) if d & (1 << 25) else 0
        t = vmaddr + i + 4 * d
        if t in targets:
            pc = vmaddr + i; fn = owner(pc)
            print(f'{targets[t]} called at {pc:#x} in {fn[1]} ({fn[0]:#x})')
PY
