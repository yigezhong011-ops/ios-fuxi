#!/bin/bash
set -euo pipefail
B=/root/fuxi/authbuild
SRC=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
OUT=/mnt/e/DSH-Fuxi/fuxi-authmon.img
python3 "$SRC/packboot4.py" "$B/Image" "$OUT"
ls -lh "$OUT"
echo "=== 校验：监控字符串与固件 ==="
python3 - "$OUT" <<'PY'
import sys, pathlib
img = pathlib.Path(sys.argv[1]).read_bytes()
print('镜像 %d B' % len(img))
for s in (b'USB monitor', b'SWEETXNU'):
    print('%-12s %s' % (s.decode(), img.find(s)))
for name, path in (('GMU','/root/fuxi/fw-correct/gmu_gen70200.bin'),
                   ('SQE','/root/fuxi/fw-correct/a740_sqe.fw'),
                   ('ZAP','/root/fuxi/fw-correct/a740_zap.mbn')):
    blob = pathlib.Path(path).read_bytes()
    print('%-4s %6d B %s' % (name, len(blob), 'FOUND' if img.find(blob) >= 0 else 'MISSING'))
PY
