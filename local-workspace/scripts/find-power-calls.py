#!/usr/bin/env python3
"""Find every place the power build script shells out, to see what still needs a
prelink candidate."""
import urllib.request

url = 'https://raw.githubusercontent.com/yigezhong011-ops/unixnu-fuxi/old/scripts/build-sheng-platform-power.py'
text = urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent': 'dsh'}), timeout=60).read().decode()
for i, line in enumerate(text.splitlines(), 1):
    if 'audit' in line or 'require(' in line or 'subprocess' in line or "run([" in line:
        print('%3d| %s' % (i, line[:150]))
