#!/usr/bin/env python3
"""Print the format-2 fuxi board.toml in full."""
import urllib.request

H = {'User-Agent': 'dsh'}
url = 'https://raw.githubusercontent.com/Star-mailaz/fuxi-ios16-device/main/board.toml'
text = urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=30).read().decode()
lines = text.splitlines()
for i, line in enumerate(lines[39:140], start=40):
    print('%3d| %s' % (i, line[:135]))
