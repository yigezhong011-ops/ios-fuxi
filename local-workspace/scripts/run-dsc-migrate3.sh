#!/bin/bash
# Read-only: where the store version 59/61 comes from in the PosterBoard framework.
cd /mnt/e/DSH-Fuxi/dump/wsl
python3 -I read-dsc-xref.py /mnt/e/DSH-Fuxi/dump/root-peek/dsc x 'Unable to setup dataStore URL' 'Unable to reach dataStore URL' 'Datastore could not be loaded' 'Data Store URLs are only valid from 59+' 2>&1 | tail -4 | cut -c1-140
python3 -I - <<'EOF'
import importlib.util, struct, sys
sys.argv = ['x', '/mnt/e/DSH-Fuxi/dump/root-peek/dsc']
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
tx, n = c.sec['__text']; t = c.rd(tx, n)
for off in range(0, n, 4):
    i = struct.unpack_from('<I', t, off)[0]
    if (i & 0x7fffffe0) in (0x528007a0, 0x52800760):         # mov w/x rd, #61 or #59
        va = tx + off
        names = []
        for o in range(off - 48, off + 64, 4):
            w = struct.unpack_from('<I', t, o)[0]
            if w & 0xfc000000 == 0x94000000:
                imm = w & 0x3ffffff
                if imm & (1 << 25): imm -= 1 << 26
                nm = c.stub(tx + o + imm * 4)
                if nm: names.append(nm[:50])
        print(hex(va), 'imm', (i >> 5) & 0xffff, 'r', i & 31, names[:7])
EOF
