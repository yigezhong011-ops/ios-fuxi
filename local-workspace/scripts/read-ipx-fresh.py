#!/usr/bin/env python3
"""Read-only: which identity the iPhone X boot's own log blocks show. Blocks whose sha1 is not in the previous capture are this boot's.
Usage: read-ipx-fresh.py <new lscan> <old lscan>"""
import hashlib
import sys


def blocks(path):
    cur, h = None, None
    lines = []
    with open(path, 'rb') as f:
        for line in f:
            if line.startswith(b'#C '):
                if cur is not None:
                    yield cur, h.digest(), lines
                cur, h, lines = line.split()[1], hashlib.sha1(), []
            elif cur is not None:
                h.update(line)
                lines.append(line)
    if cur is not None:
        yield cur, h.digest(), lines


old = {d for _, d, _ in blocks(sys.argv[2])}
print('old blocks', len(old))
keys = [b'iPhone10,3', b'iPhone15,2', b'iPhone14,3', b'iPhone X', b'iPhone 14 Pro', b'iPhone 13 Pro Max', b'iPhone 13PM', b'ArtworkDeviceSubType', b'ArtworkDeviceProductDescription',
        b'MobileGestaltHelper', b'com.apple.MobileGestalt.plist', b'mobilegestaltcache', b'rdar', b'StatusBar', b'statusBar', b'status bar']
count = dict.fromkeys(keys, 0)
samples = {k: [] for k in keys}
fresh = 0
for _, d, lines in blocks(sys.argv[1]):
    if d in old:
        continue
    fresh += 1
    for line in lines:
        for k in keys:
            if k in line:
                count[k] += 1
                if len(samples[k]) < 5 and len(line) < 300:
                    t = line.strip()[:180].decode('utf-8', 'replace')
                    if t not in samples[k]:
                        samples[k].append(t)
print('fresh blocks', fresh)
for k in keys:
    print(k.decode(), count[k])
    for s in samples[k]:
        print('    ', s)
