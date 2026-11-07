#!/bin/bash
# Scratch venv under /root/fuxi for zopfli, and a trial on the two big plugin entries. Reads the addon only.
V=/root/fuxi/zopfli-venv
[ -x $V/bin/python ] || python3 -m venv $V
$V/bin/python -m pip install -q zopfli 2>&1 | tail -1
cat > /tmp/zt.py <<'EOF'
import struct, time, zlib, zopfli.zlib
b = open('/root/fuxi/gpu-plugin-m2v/gpuaddon.bin', 'rb').read()
c = struct.unpack_from('<I', b, 8)[0]; at = 24
for _ in range(c):
    nl, m, s, pk = struct.unpack_from('<IIQQ', b, at); at += 24
    n = b[at:at + nl - 1].decode(); at += (nl + 7) // 8 * 8
    d = b[at:at + pk]; at += (pk + 7) // 8 * 8
    if pk > 1000000:
        raw = zlib.decompress(d); t = time.time()
        z = zopfli.zlib.compress(raw, numiterations=5, blocksplitting=True)
        assert zlib.decompress(z) == raw
        print(n.split('/')[-1], pk, '->', len(z), 'saved', pk - len(z), '%.0f s' % (time.time() - t), flush=True)
EOF
$V/bin/python -I /tmp/zt.py
