#!/bin/bash
# Read-only: resolve the attribute constants one level deeper; the function behind the isUpToDate attribute dictionary; the base URL lines in the log.
cd /mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc; L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
python3 -I - $D <<'EOF'
import importlib.util, struct, sys
sys.argv = ['x', sys.argv[1]]
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
M = 0xfffffffff
def q(a):
    d = c.rd(a, 8)
    return struct.unpack('<Q', d)[0] if d else None
def show(g):
    p = q(g) & M              # the constant's address
    v = q(p)
    out = [hex(p)]
    if v is None: return out
    o = v & M
    if o < 0x180000000: o += 0x180000000
    out.append(hex(o))
    s = q(o + 16)
    if s:
        t = s & M
        if t < 0x180000000: t += 0x180000000
        out.append(repr(c.cstr(t)))
    return out
for g in (0x1f350cfe0, 0x1f350cfe8, 0x1f350d020, 0x1f350d3a8):
    print(hex(g), show(g))
for a, nm in sorted((x[0], x[1]) for x in c.images):
    pass
imgs = sorted(c.images)
import bisect
A = [x[0] for x in imgs]
print('image of 0x1a82cdb4c:', imgs[bisect.bisect_right(A, 0x1a82cdb4c) - 1][1])
EOF
llvm-nm --version >/dev/null 2>&1
echo "=== dump at 0x1a82cdb4c"
python3 -I read-store-build.py $D 1a82cdb4c 40 | grep -v '^{' | cut -c1-100 | head -18
echo "=== base URL lines"
grep -a -c 'PRBPosterExtensionDataStore/$' $L
grep -a -n 'PRBPosterExtensionDataStore/$' $L | head -5 | sed -E 's/[0-9A-F]{8}-[0-9A-F-]{27}/#/g' | cut -c1-150
grep -a -n -E 'ExtensionDataStore' $L | sed -E 's/[0-9A-F]{8}-[0-9A-F-]{27}/#/g' | cut -c1-150 | head -16
grep -a -c 'Error validating' $L
