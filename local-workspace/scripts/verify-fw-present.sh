#!/bin/bash
set -uo pipefail
IMG=/mnt/e/DSH-Fuxi/fuxi-pkgmon.img
python3 - "$IMG" <<'PY'
import sys, pathlib, hashlib
img = pathlib.Path(sys.argv[1]).read_bytes()
print('镜像 %d 字节' % len(img))
for name, path in (('GMU', '/root/fuxi/fw-correct/gmu_gen70200.bin'),
                   ('SQE', '/root/fuxi/fw-correct/a740_sqe.fw'),
                   ('ZAP', '/root/fuxi/fw-correct/a740_zap.mbn')):
    blob = pathlib.Path(path).read_bytes()
    i = img.find(blob)
    ok = 'FOUND' if i >= 0 else 'MISSING'
    print('%-4s %6d B  %s  offset=%s' % (name, len(blob), ok, i))
for s in (b'USB monitor', b'MON_MAGIC', b'FUXI TOUCH', b'Sweet'):
    print('%-14s %s' % (s.decode(errors='replace'), img.find(s)))
PY
