#!/usr/bin/env python3
"""Replace the two garbled share-* copy lines (20 and 21) of sync-ios-fuxi-1103.sh with glob copies."""
p = '/mnt/e/DSH-Fuxi/dump/wsl/sync-ios-fuxi-1103.sh'
raw = open(p, 'rb').read()
if raw.startswith(b'\xef\xbb\xbf'):
    raw = raw[3:]
lines = raw.split(b'\n')
for i, l in enumerate(lines):
    if l.startswith(b'cp "$E/share-brightness/'):
        lines[i] = b'cp "$E"/share-brightness/README-*.md "$DEST/share-brightness/"'
    elif l.startswith(b'cp "$E/share-for-author/'):
        lines[i] = b'cp "$E"/share-for-author/README-*.md "$DEST/share-for-author/"'
open(p, 'wb').write(b'\n'.join(lines))
print('fixed')
