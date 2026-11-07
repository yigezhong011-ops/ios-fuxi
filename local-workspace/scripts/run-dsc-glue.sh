#!/bin/bash
# Read-only: the data store setup path with call names.
cd /mnt/e/DSH-Fuxi/dump/wsl
python3 -I read-dsc-build.py /mnt/e/DSH-Fuxi/dump/root-peek/dsc 2>&1 | grep -v '^{' | sed -n '/-- func/,/== strings/p' | cut -c1-130 | head -40
python3 -I - <<'EOF'
import importlib.util, struct, sys
sys.argv = ['x', '/mnt/e/DSH-Fuxi/dump/root-peek/dsc']
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
tx, n = c.sec['__text']; t = c.rd(tx, n)
cfs = {}
def calls(a, b, label):
    print('==', label)
    for va in range(a, b, 4):
        w = struct.unpack_from('<I', t, va - tx)[0]
        if w & 0xfc000000 == 0x94000000:
            imm = w & 0x3ffffff
            if imm & (1 << 25): imm -= 1 << 26
            nm = c.stub(va + imm * 4)
            print(hex(va), 'bl', (nm or hex(va + imm * 4))[:90])
        elif w == 0xd65fcfff or w == 0xd65f03c0:
            print(hex(va), 'ret')
        elif w & 0xff000000 in (0xb4000000, 0xb5000000, 0x34000000, 0x35000000):
            imm = (w >> 5) & 0x7ffff
            if imm & (1 << 18): imm -= 1 << 19
            print(hex(va), 'cb' + ('nz' if w & 0x01000000 else 'z'), 'r%d' % (w & 31), hex(va + imm * 4))
calls(0x1ca9153a0, 0x1ca915600, 'glue around Unable to setup/reach dataStore URL')
calls(0x1ca915c80, 0x1ca915d80, 'glue around Datastore could not be loaded')
calls(0x1ca89e430, 0x1ca89e540, 'store coordinator: sqlite url at 61')
EOF
