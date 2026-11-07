#!/bin/bash
# native_hid_input_probe_body: which boot arguments decide between the full input device (buttons) and the touch-only one.
# Resolves the adrp/add string operands of PE_parse_boot_argn calls and prints the branches around both allocator calls.
K=/root/fuxi/t32/kernel.macho
llvm-objdump -d --no-show-raw-insn --start-address=0xfffffff00c021dc0 --stop-address=0xfffffff00c022260 "$K" | tail -n +7 > /tmp/probe.txt
python3 - "$K" <<'PY'
import re, struct, sys
k = open(sys.argv[1], 'rb').read()
ncmds = struct.unpack_from('<I', k, 16)[0]; segs = []; off = 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, off)
    if cmd == 0x19:
        vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<4Q', k, off + 24); segs.append((vmaddr, fileoff, filesize))
    off += size
def cstr(va):
    for vmaddr, fileoff, filesize in segs:
        if vmaddr <= va < vmaddr + filesize:
            o = fileoff + va - vmaddr; return k[o:k.index(b'\0', o)][:60].decode(errors='replace')
regs = {}
for l in open('/tmp/probe.txt'):
    l = l.rstrip()
    m = re.search(r'adrp\s+(x\d+), (0x[0-9a-f]+)', l)
    if m: regs[m.group(1)] = int(m.group(2), 16)
    m2 = re.search(r'add\s+(x\d+), (x\d+), #(0x[0-9a-f]+)', l)
    if m2 and m2.group(2) in regs: regs[m2.group(1)] = regs[m2.group(2)] + int(m2.group(3), 16)
    note = ''
    if ('PE_parse_boot_argn' in l or 'strcmp' in l or 'strncmp' in l) and 'x0' in regs:
        note = f'    ; "{cstr(regs["x0"])}"'
    if any(t in l for t in ('PE_parse_boot_argn', 'allocate', 'cbz', 'cbnz', 'tbz', 'tbnz', 'b.', 'cmp ', 'ret', 'bl\t')):
        print(l + note)
PY
