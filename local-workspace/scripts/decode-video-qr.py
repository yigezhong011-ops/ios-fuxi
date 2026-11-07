#!/usr/bin/env python3
"""Decode the Advanced Logger QR pages from the video frames and assemble the log text.

Each page carries a fragment of the same log; the pages rotate in order, so the fragments
are collected by decode order and joined. Duplicates (the same page captured twice) are
dropped by payload.
"""
import glob
import os
import subprocess
from pathlib import Path

import cv2

VIDEO = '/mnt/e/xwechat_files/wxid_ufcunrrmn9p22_4361/msg/video/2026-11/aef28ec4a243fc51273870d14bb70bb0.mp4'
OUT = Path('/root/qr')
FRAMES = OUT / 'frames'

OUT.mkdir(exist_ok=True)
FRAMES.mkdir(exist_ok=True)
for old in FRAMES.glob('*.png'):
    old.unlink()

print('抽取帧...')
subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-i', VIDEO,
                '-vf', 'fps=3', '-y', str(FRAMES / 'f%04d.png')], check=True)
frames = sorted(FRAMES.glob('*.png'))
print('共 %d 帧' % len(frames))

det = cv2.QRCodeDetector()


def decode(img):
    ok, decoded, _, _ = det.detectAndDecodeMulti(img)
    if ok and decoded:
        text = ''.join(decoded)
        if len(text) > 4:
            return text
    return None


def page_crop(img):
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    _, th = cv2.threshold(gray, 185, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(th, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    best, box = 0, None
    for c in contours:
        area = cv2.contourArea(c)
        if area <= best:
            continue
        x, y, w, h = cv2.boundingRect(c)
        if w > 150 and h > 150:
            best, box = area, (x, y, w, h)
    if not box:
        return None
    x, y, w, h = box
    return img[max(0, y - 4):y + h + 4, max(0, x - 4):x + w + 4]


pages = {}
for i, f in enumerate(frames):
    img = cv2.imread(str(f))
    text = decode(img)
    if not text:
        crop = page_crop(img)
        if crop is not None:
            for scale in (2, 3, 4):
                big = cv2.resize(crop, None, fx=scale, fy=scale, interpolation=cv2.INTER_CUBIC)
                text = decode(big)
                if text:
                    break
                g = cv2.cvtColor(big, cv2.COLOR_BGR2GRAY)
                _, bw = cv2.threshold(g, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
                text = decode(cv2.cvtColor(bw, cv2.COLOR_GRAY2BGR))
                if text:
                    break
    status = 'OK  %d chars' % len(text) if text else '-'
    print('%s  %s' % (f.name, status))
    if text:
        pages.setdefault(text, (i, f.name))

print('\n唯一页数: %d' % len(pages))
ordered = sorted(pages.items(), key=lambda kv: kv[1][0])
with (OUT / 'pages.txt').open('w') as fh:
    for text, (idx, name) in ordered:
        fh.write('### %s\n%s\n' % (name, text))
print('已写入', OUT / 'pages.txt')
