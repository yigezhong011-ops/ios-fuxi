#!/usr/bin/env python3
"""Decode an Advanced Logger QR page even when the phone photo is dense: find the white
page, upscale it, and retry with several threshold strategies."""
import sys

import cv2
import numpy as np

path = sys.argv[1]
img = cv2.imread(path)
print('image %dx%d' % (img.shape[1], img.shape[0]))
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# the QR page is the brightest large rectangle; find it by thresholding then taking the
# biggest quadrilateral contour
_, th = cv2.threshold(gray, 190, 255, cv2.THRESH_BINARY)
contours, _ = cv2.findContours(th, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
box = None
best = 0
for c in contours:
    area = cv2.contourArea(c)
    if area < (gray.size * 0.05) or area <= best:
        continue
    x, y, w, h = cv2.boundingRect(c)
    if w < 200 or h < 200:
        continue
    box = (x, y, w, h)
    best = area
print('page box:', box)

crops = []
if box:
    x, y, w, h = box
    pad = int(w * 0.02)
    crops.append(img[max(0, y - pad):y + h + pad, max(0, x - pad):x + w + pad])
h, w = img.shape[:2]
crops.append(img[int(h * 0.42):int(h * 0.75), int(w * 0.2):int(w * 0.8)])

det = cv2.QRCodeDetector()
for i, crop in enumerate(crops):
    for scale in (1, 2, 3):
        c = crop if scale == 1 else cv2.resize(crop, None, fx=scale, fy=scale,
                                               interpolation=cv2.INTER_CUBIC)
        variants = [c]
        g = cv2.cvtColor(c, cv2.COLOR_BGR2GRAY)
        variants.append(cv2.cvtColor(cv2.adaptiveThreshold(
            g, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 31, 10), cv2.COLOR_GRAY2BGR))
        variants.append(cv2.cvtColor(cv2.threshold(g, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1],
                                     cv2.COLOR_GRAY2BGR))
        for j, v in enumerate(variants):
            ok, decoded, _, _ = det.detectAndDecodeMulti(v)
            if ok and decoded:
                text = ''.join(decoded)
                if len(text) > 8:
                    print('crop %d scale %d variant %d: %d chars' % (i, scale, j, len(text)))
                    print(text[:2000])
                    sys.exit(0)
print('no full decode; try a straighter, closer photo of the QR only')
