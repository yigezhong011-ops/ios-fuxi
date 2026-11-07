#!/bin/bash
# Read-only: does the system call fcntl 64 for NSFileProtectionKey; how strict is the conform check; what precedes bare "Operation not supported" in the log.
cd /mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc; L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
echo "== callers"
python3 -I - $D <<'EOF'
import importlib.util, struct, sys, bisect
sys.argv = ['x', sys.argv[1]]
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
imgs = sorted(c.images); A = [x[0] for x in imgs]
tx, n = c.sec['__text']; t = c.rd(tx, n)
want = ('getResourceValue:forKey:error:', 'resourceValuesForKeys:error:', 'isEqual:', 'setResourceValues:error:')
names = {}; out = {w: [] for w in want}
for off in range(0, n, 4):
    i = struct.unpack_from('<I', t, off)[0]
    if i & 0xfc000000 != 0x94000000: continue
    imm = i & 0x3ffffff
    if imm & (1 << 25): imm -= 1 << 26
    va = tx + off; to = va + imm * 4
    if to not in names: names[to] = c.stub(to)
    if names[to] in out: out[names[to]].append(va)
for k, v in out.items(): print(k, len(v), ' '.join(hex(x) for x in v if 0x1ca9a0000 < x < 0x1ca9c0000)[:400])
# images that hold fcntl(fd, 64, ...): mov w1,#0x40 then bl into a stub, in Foundation and CoreFoundation
for name in ('/Foundation.framework/Foundation', '/CoreFoundation.framework/CoreFoundation', '/CoreServicesInternal.framework/CoreServicesInternal', '/libFoundation'):
    hits = [x for x in imgs if x[1].endswith(name)]
    if not hits: continue
    base = hits[0][0]
    hdr = c.rd(base, 0x8000)
    ncmd = struct.unpack_from('<I', hdr, 16)[0]; at = 32; text = None
    for _ in range(ncmd):
        cmd, size = struct.unpack_from('<II', hdr, at)
        if cmd == 0x19:
            ns = struct.unpack_from('<I', hdr, at + 64)[0]
            for j in range(ns):
                s = at + 72 + j * 80
                if hdr[s:s + 16].rstrip(b'\0') == b'__text':
                    text = struct.unpack_from('<QQ', hdr, s + 32)
        at += size
    b = c.rd(text[0], text[1])
    found = []
    for o in range(0, text[1] - 32, 4):
        if struct.unpack_from('<I', b, o)[0] == 0x52800801:   # mov w1,#0x40
            found.append(text[0] + o)
    print(name, hex(text[0]), 'mov w1,#64 sites', len(found), ' '.join(hex(x) for x in found[:12]))
EOF
echo "== Operation not supported neighbours"
grep -a -n -m 200000 -B1 '^Operation not supported$' $L | grep -a -v -E 'Operation not supported$|^--$' | sed -E 's/^[0-9]+-//; s/0x[0-9a-f]+/#/g; s/[0-9A-F]{8}-[0-9A-F-]{27}/#/g; s/[0-9]+/N/g' | cut -c1-110 | sort | uniq -c | sort -rn | head -8
