#!/bin/bash
set -uo pipefail
python3 - <<'PY'
import cv2
from pyzbar.pyzbar import decode
p = "/mnt/c/Users/USER/.dsh/attachments/v1/objects/ab/abecdaf40a5d0735173606a9866f9999144dc2923eb3ce06731cf968bb43a087"
img = cv2.imread(p)
print('photo', img.shape)
best = None
for box in ((255, 875, 530, 530), (240, 860, 560, 560)):
    x, y, w, h = box
    crop = img[y:y+h, x:x+w]
    for scale in (2, 3, 4):
        c = cv2.resize(crop, None, fx=scale, fy=scale, interpolation=cv2.INTER_CUBIC)
        gray = cv2.cvtColor(c, cv2.COLOR_BGR2GRAY)
        for name, v in (('gray', gray),
                        ('otsu', cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1])):
            for r in decode(v):
                text = r.data.decode('utf-8', 'replace')
                if best is None or len(text) > len(best):
                    best = text
                    print('scale %d %s: %d chars' % (scale, name, len(text)))
print('--- 结果 ---')
print(best[:1200] if best else '（没解出来）')
PY
