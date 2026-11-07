#!/usr/bin/env python3
"""Read the format-2 fuxi repo's README and DISPLAY-ABI note."""
import urllib.request

H = {'User-Agent': 'dsh'}
BASE = 'https://raw.githubusercontent.com/Star-mailaz/fuxi-ios16-device/main/'


def get(path):
    try:
        return urllib.request.urlopen(urllib.request.Request(BASE + path, headers=H), timeout=30).read().decode('utf-8', 'replace')
    except Exception as e:
        return '(读取失败 %s)' % e


readme = get('README.md')
print('=== README（前 60 行）===')
for line in readme.splitlines()[:60]:
    print('  ', line[:130])
