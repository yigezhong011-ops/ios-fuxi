#!/bin/bash
set -uo pipefail
apt-get install -y -q libzbar0 >/dev/null 2>&1 || echo "（apt 装 libzbar0 失败）"
pip install --break-system-packages -q pyzbar 2>&1 | tail -2
python3 - <<'PY'
import cv2
from pyzbar.pyzbar import decode
img = cv2.imread('/root/qr/frames/f0020.png')
print('frame', img.shape)
best = None
for scale in (1, 2, 3, 4):
    crop = img[460:790, 150:530]
    c = crop if scale == 1 else cv2.resize(crop, None, fx=scale, fy=scale, interpolation=cv2.INTER_CUBIC)
    gray = cv2.cvtColor(c, cv2.COLOR_BGR2GRAY)
    for name, v in (('gray', gray),
                    ('otsu', cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]),
                    ('adapt', cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                                    cv2.THRESH_BINARY, 25, 10))):
        res = decode(v)
        for r in res:
            text = r.data.decode('utf-8', 'replace')
            print('scale %d %s: %d chars' % (scale, name, len(text)))
            if best is None or len(text) > len(best):
                best = text
print('--- 最长结果 ---')
print(best[:1500] if best else '（没解出来）')
PY
