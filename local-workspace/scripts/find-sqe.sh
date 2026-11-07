#!/bin/bash
set -uo pipefail
IMG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/boot-gpu3-v4.img
ZAP=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/a740_zap-odm-fd107982.mbn
python3 - "$IMG" "$ZAP" <<'PY'
import sys, hashlib
img = open(sys.argv[1], 'rb').read()
zap = open(sys.argv[2], 'rb').read()
print('镜像大小 %d, zap %d' % (len(img), len(zap)))
z = img.find(zap)
print('zap 偏移:', z)
if z < 0:
    raise SystemExit('zap 未找到')
# 常见布局：GMU(66844) + SQE(75380) + ZAP(12088) 相邻
for sqe_len in (75380, 76724):
    s = z - sqe_len
    if s < 0:
        continue
    blob = img[s:z]
    print('候选 SQE @%d len=%d sha=%s' % (s, sqe_len, hashlib.sha256(blob).hexdigest()[:16]))
    g = s - 66844
    if g >= 0:
        gm = img[g:s]
        print('  候选 GMU @%d len=66844 sha=%s' % (g, hashlib.sha256(gm).hexdigest()[:16]))
PY
