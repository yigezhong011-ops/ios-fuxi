#!/usr/bin/env python3
# Read-only: finds code references to the USB control verb strings in the t50 disassembly, using the Mach-O segment table for addresses.
import re, struct
K = '/root/fuxi/t50/kernel.macho'; D = '/root/fuxi/t50.dis'
data = open(K, 'rb').read()
ncmds = struct.unpack_from('<I', data, 16)[0]
off = 32; segs = []
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', data, off)
    if cmd == 0x19:
        name = data[off + 8:off + 24].split(b'\0')[0].decode()
        vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<QQQQ', data, off + 24)
        segs.append((name, vmaddr, vmsize, fileoff, filesize))
    off += size
for s in segs:
    print('%-18s va %x size %x file %x size %x' % (s[0], s[1], s[2], s[3], s[4]))
def to_va(o):
    for n, va, vs, fo, fs in segs:
        if fs and fo <= o < fo + fs:
            return va + o - fo, n
    return None, None
VERBS = [b'HELLO', b'PING', b'REBOOT', b'SCREENSHOT', b'SHOTNEXT', b'STATUS', b'TOUCH']
targets = {}
for v in VERBS:
    for m in re.finditer(b'(?<=\\0)' + v + b'\\0', data):
        va, seg = to_va(m.start())
        print(v.decode(), 'file %x va %s seg %s' % (m.start(), hex(va) if va else None, seg))
        if va:
            targets[va] = v.decode()
lines = open(D, errors='replace').read().split('\n')
adrp_re = re.compile(r'\badrp\s+(x\d+),\s*(?:0x)?([0-9a-f]+)')
adr_re = re.compile(r'\badr\s+(x\d+),\s*(?:0x)?([0-9a-f]+)')
add_re = re.compile(r'\badd\s+(x\d+),\s*(x\d+),\s*#(0x[0-9a-f]+|\d+)')
regs = {}; hits = []
for i, l in enumerate(lines):
    m = adr_re.search(l)
    if m and int(m.group(2), 16) in targets:
        hits.append((i, targets[int(m.group(2), 16)])); continue
    m = adrp_re.search(l)
    if m:
        regs[m.group(1)] = (int(m.group(2), 16), i); continue
    m = add_re.search(l)
    if m and m.group(2) in regs and i - regs[m.group(2)][1] < 40:
        va = regs[m.group(2)][0] + int(m.group(3), 0)
        if va in targets:
            hits.append((i, targets[va]))
print('xrefs:', len(hits))
for i, n in hits:
    print(' ', n, lines[i].strip()[:80])
# The dispatcher: from the first verb reference, enough lines to show how verbs are compared and which take arguments.
verb_hits = [i for i, n in hits if n in ('HELLO', 'SCREENSHOT')]
if verb_hits:
    a = min(verb_hits)
    print('--- dispatcher from first verb reference')
    print('\n'.join(x[:90] for x in lines[max(0, a - 10):a + 60]))
for i, n in hits:
    if n == 'TOUCH':
        print('--- around TOUCH xref')
        print('\n'.join(x[:90] for x in lines[max(0, i - 15):i + 40]))
