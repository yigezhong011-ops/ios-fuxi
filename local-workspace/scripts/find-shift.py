#!/usr/bin/env python3
"""Where does the phone's block 1 (4 MiB) content come from: a shifted part of the local image, or older data?"""
import sys
img = sys.argv[1]
rb = open('/root/fuxi/rb.bin', 'rb').read()
data = open(img, 'rb').read(256 << 20)
probe = rb[4096:4096 + 64]
at = data.find(probe)
print('probe found in local image at', at, '(block1 page1 offset', (4 << 20) + 4096, ')', 'shift', at - ((4 << 20) + 4096) if at >= 0 else None)
old = '/mnt/e/DSH-Fuxi/待删除/gles-root10-libs.simg'
print('remote equals zero pages:', rb.count(b'\0' * 4096))
