#!/bin/bash
# Read-only: the attribute dictionaries' contents, and the ENOTSUP returns in t50's fcntl.
cd /mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc; K=/root/fuxi/t50/kernel.macho
python3 -I - $D <<'EOF'
import importlib.util, struct, sys
sys.argv = ['x', sys.argv[1]]
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
M = 0xfffffffff
def q(a):
    d = c.rd(a, 8)
    return struct.unpack('<Q', d)[0] if d else None
def name(g):
    p = q(g) & M
    v = q(p)
    if v is None: return hex(p)
    o = v & M
    if o < 0x180000000: o += 0x180000000
    s = q(o + 16)
    if s:
        t = s & M
        if t < 0x180000000: t += 0x180000000
        return c.cstr(t) or hex(o)
    return hex(o)
for g in (0x1eb648150, 0x1eb648180, 0x1eb648188, 0x1eb63b4e8, 0x1eb63bc58, 0x1eb63b410, 0x1eb63b418):
    print(hex(g), name(g))
EOF
python3 -I read-store-build.py $D 1a82cdac0 50 | grep -v '^{' | cut -c1-80
python3 -I read-store-build.py $D 1a82cdba4 40 | grep -v '^{' | cut -c1-80
echo "== fcntl size and ENOTSUP sites"
A=$(llvm-nm -n $K | awk '$3=="_sys_fcntl_nocancel"{print $1; f=1; next} f{print $1; exit}')
set -- $A; echo "$1 $2"
llvm-objdump -d --start-address=0x$1 --stop-address=0x$2 $K 2>/dev/null | tail -n +7 | cut -c19-100 > /tmp/fcntl.txt
wc -l /tmp/fcntl.txt
grep -n -E '#0x2d\b|=45\b|#0x3f\b|#0x40\b|_VNOP_SETATTR|_VNOP_GETATTR|_vnode_getattr|_vnode_setattr|_vnode_authorize|br\s+x' /tmp/fcntl.txt | cut -c1-90 | head -40
