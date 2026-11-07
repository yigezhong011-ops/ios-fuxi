#!/bin/bash
# Read only: where our kernel keeps the rejected surface fields.
K=/root/fuxi/t50-gpu7/kernel.macho
llvm-nm --defined-only $K 2>/dev/null | sort | awk '$1>="fffffff00c181ee0" && $1<="fffffff00c181fb0"' | cut -c1-70
echo; llvm-nm --defined-only $K 2>/dev/null | sort | grep -E -A1 ' _native_legacy_surface_rejected$| _native_legacy_swap_validation_observed$' | cut -c1-70
echo; llvm-objdump -d --no-show-raw-insn --start-address=0xfffffff00c01f934 --stop-address=0xfffffff00c01f9d0 $K | tail -n +7 | cut -c1-80 | head -40
echo; python3 -I - <<'EOF'
import struct
b = open('/root/fuxi/t50-gpu7/kernel.macho','rb').read()
n = struct.unpack_from('<I', b, 16)[0]; at = 32
secs = []
for _ in range(n):
    c, sz = struct.unpack_from('<II', b, at)
    if c == 0x19:
        name = b[at+8:at+24].split(b'\0')[0].decode(); va, vs, fo, fs = struct.unpack_from('<QQQQ', b, at+24); secs.append((name, va, vs, fo, fs))
    at += sz
for addr in (0xfffffff00c01f934,):
    for name, va, vs, fo, fs in secs:
        if va <= addr < va + fs:
            d = b[fo + addr - va:fo + addr - va + 0xa0]
            print(name, 'words', [hex(x) for x in struct.unpack('<40I', d)])
EOF
grep -n 'FUXI120S\|printf\|ADDR_\|__attribute__' /mnt/e/DSH-Fuxi/dump/wsl/touch-cave2.c | cut -c1-150 | head -50
