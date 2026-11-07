#!/bin/bash
# Read-only: the migration loop, the tail of migrateDataStoreAtBaseURL, the option bits, min and current versions.
cd /mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc
echo "== store init options"; python3 -I read-store-build.py $D 1ca835074 30 | grep -v '^{' | cut -c1-100
echo "== loop"; python3 -I read-store-build.py $D 1ca89e0b4 3d0 | grep -v '^{' | cut -c1-112 | grep -v -E '\b(ldr|str|stp|ldp|stur|ldur|adrp)\b.*(sp|x29)' | head -210
echo "== tail"; python3 -I read-store-build.py $D 1ca89f920 a0 | grep -v '^{' | cut -c1-112
echo "== db init head"; python3 -I read-store-build.py $D 1ca8d6bd0 d0 | grep -v '^{' | cut -c1-112
echo "== version constants"
python3 -I - $D <<'EOF'
import importlib.util, struct, sys
sys.argv = ['x', sys.argv[1]]
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
tx, n = c.sec['__text']; t = c.rd(tx, n)
# small leaf methods returning a constant 40..70: mov x0/w0,#imm ; ret
for off in range(0, n - 8, 4):
    a, b = struct.unpack_from('<II', t, off)
    if b == 0xd65f03c0 and (a & 0x7fe0001f) in (0x52800000,) or (b == 0xd65f03c0 and a & 0xffe0001f == 0xd2800000):
        v = (a >> 5) & 0xffff
        if 55 <= v <= 65:
            print(hex(tx + off), 'returns', v)
EOF
