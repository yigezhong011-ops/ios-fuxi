#!/bin/bash
# Read-only: how Foundation applies NSFileProtectionKey. Sites of mov w1,#64 with the call that follows, and of setattrlist's attrgroup 0x40000000.
cd /mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc
python3 -I - $D <<'EOF'
import importlib.util, struct, sys, re
sys.argv = ['x', sys.argv[1]]
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
M = 0xfffffffff
imgs = sorted(c.images)
base = [x for x in imgs if x[1].endswith('/Foundation.framework/Foundation')][0][0]
hdr = c.rd(base, 0x8000)
ncmd = struct.unpack_from('<I', hdr, 16)[0]; at = 32; secs = {}
for _ in range(ncmd):
    cmd, size = struct.unpack_from('<II', hdr, at)
    if cmd == 0x19:
        ns = struct.unpack_from('<I', hdr, at + 64)[0]
        for j in range(ns):
            s = at + 72 + j * 80
            secs[hdr[s:s + 16].rstrip(b'\0').decode()] = struct.unpack_from('<QQ', hdr, s + 32)
    at += size
tx, n = secs['__text']; t = c.rd(tx, n)
# Who loads the NSFileProtectionKey constant? Find its CFString, then the data pointer and code that reads that symbol.
d = {}
for name in ('__cstring',):
    a, l = secs[name]; b = c.rd(a, l)
    for m in re.finditer(rb'NSFileProtectionKey\0', b):
        d[a + m.start()] = 1
    for m in re.finditer(rb'[^\0]*(F_SETPROTECTIONCLASS|setattrlist|protection class|file protection)[^\0]*', b, re.I):
        print('str', hex(a + m.start()), m[0][:120])
print('cstr', [hex(x) for x in d])
sites = []
for off in range(0, n - 40, 4):
    if struct.unpack_from('<I', t, off)[0] != 0x52800801: continue
    va = tx + off
    # next bl within 8 instructions, and whether a register-ish fd comes from open
    for k in range(1, 9):
        i = struct.unpack_from('<I', t, off + 4 * k)[0]
        if i & 0xfc000000 == 0x94000000:
            imm = i & 0x3ffffff
            if imm & (1 << 25): imm -= 1 << 26
            to = va + 4 * k + imm * 4
            sites.append((va, to)); break
from collections import Counter
print(Counter(hex(x[1]) for x in sites).most_common(8))
for va, to in sites[:60]:
    code = c.rd(to, 12)
    if code:
        a, b = struct.unpack_from('<II', code)
    print(hex(va), '->', hex(to))
EOF
