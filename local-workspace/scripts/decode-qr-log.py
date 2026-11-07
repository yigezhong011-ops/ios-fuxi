#!/usr/bin/env python3
"""Decode the Advanced Logger QR pages so the firmware log can be searched for USB lines."""
import sys

import cv2

path = sys.argv[1]
img = cv2.imread(path)
print('图像 %s  %dx%d' % (path, img.shape[1], img.shape[0]))

detector = cv2.QRCodeDetector()
data, points, _ = detector.detectAndDecode(img)
if data:
    print('=== 解码成功，%d 字符 ===' % len(data))
    print(data)
else:
    # try a few crops/scales: the QR sits in the middle of the phone photo
    h, w = img.shape[:2]
    found = False
    for frac in (0.5, 0.6, 0.7, 0.8, 0.9):
        y0 = int(h * (1 - frac) * 0.55)
        y1 = int(h * (0.55 + (1 - frac) * 0.45))
        x0 = int(w * (1 - frac) / 2)
        x1 = w - x0
        crop = img[y0:y1, x0:x1]
        ok, decoded, _, _ = detector.detectAndDecodeMulti(crop)
        if ok and decoded and decoded[0]:
            print('=== 裁剪 %.1f 解码成功，%d 字符 ===' % (frac, len(decoded[0])))
            print(decoded[0])
            found = True
            break
    if not found:
        print('这张没解出来（可能有反光/倾斜/模糊）')
