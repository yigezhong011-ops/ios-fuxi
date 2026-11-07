#!/bin/bash
# Where NativeHidInput::start sets the byte flags at +0xe0..+0xe4 (the 0xe3 one gates native_buttons_set_sink), and which boot
# arguments it parses: the strings the PE_parse_boot_argn calls take, resolved from their adrp/add pairs.
K=/root/fuxi/t32/kernel.macho
llvm-objdump -d --no-show-raw-insn --start-address=0xfffffff00c0315b8 --stop-address=0xfffffff00c0317f4 "$K" | tail -n +7 > /tmp/hidstart.txt
echo "== stores to +0xe0..+0xe4"
grep -n -E 'strb.*#0xe[0-4]\]|strh.*#0xe[0-4]\]|str\s+w.*#0xe[0-4]\]' /tmp/hidstart.txt
echo "== boot-arg names passed to PE_parse_boot_argn"
python3 - "$K" <<'PY'
import re, struct, subprocess, sys
k = open(sys.argv[1], 'rb').read()
lines = open('/tmp/hidstart.txt').read().splitlines()
ncmds = struct.unpack_from('<I', k, 16)[0]; segs = []; off = 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, off)
    if cmd == 0x19:
        vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<4Q', k, off + 24); segs.append((vmaddr, fileoff, filesize))
    off += size
def cstr(va):
    for vmaddr, fileoff, filesize in segs:
        if vmaddr <= va < vmaddr + filesize:
            o = fileoff + va - vmaddr; return k[o:k.index(b'\0', o)].decode(errors='replace')
regs = {}
for l in lines:
    m = re.search(r'adrp\s+(x\d+), (0x[0-9a-f]+)', l)
    if m: regs[m.group(1)] = int(m.group(2), 16); continue
    m = re.search(r'add\s+(x\d+), (x\d+), #(0x[0-9a-f]+)', l)
    if m and m.group(2) in regs: regs[m.group(1)] = regs[m.group(2)] + int(m.group(3), 16); continue
    if 'PE_parse_boot_argn' in l and 'x0' in regs:
        print('  ', l.split(':')[0].strip(), cstr(regs['x0']))
PY
echo "== full listing lines 1-80 (start of start())"
sed -n '1,80p' /tmp/hidstart.txt
